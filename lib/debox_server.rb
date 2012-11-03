require 'json'
require 'fileutils'
require 'erb'

require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/namespace'
require "sinatra/streaming"

require "debox_server/version"
require "debox_server/utils"
require "debox_server/config"
require "debox_server/users"
require "debox_server/recipes"
require "debox_server/deployer"
require "debox_server/basic_auth"

# Only redis backend for now
require 'debox_server/redis'

# TODO get root without the ../
DEBOX_ROOT = File.join(File.dirname(__FILE__), '../')


module DeboxServer

  module App
    include DeboxServer::Utils
    include DeboxServer::Config
    include DeboxServer::RedisDB
    include DeboxServer::Users
    include DeboxServer::Recipes
    include DeboxServer::Deployer
  end

  class Core
    include DeboxServer::App
  end

  class HTTP < Sinatra::Base
    set :root, DEBOX_ROOT

    require 'rack'
    include DeboxServer::App
    include DeboxServer::BasicAuth

    register Sinatra::Namespace
    helpers Sinatra::Streaming
    helpers Sinatra::JSON


    # TODO auto reload please!!
    configure :development do
      use Rack::Reloader
    end

    get "/" do
      "debox"
    end

    # Return the api_key for the user
    post "/api_key" do
      user = login_user(params[:user], params[:password])
      throw(:halt, [401, "Not authorized\n"]) unless user
      user.api_key
    end

    # API
    #----------------------------------------------------------------------

    # Require api_key
    before '/api/*'  do
      authenticate!
    end

    namespace '/api' do
      # Return a list with users in the system
      get '/users' do
        json users_config.keys
      end

      # Users
      #----------------------------------------------------------------------

      post '/users/create' do
        user = add_user params[:user], params[:password]
        throw(:halt, [400, "Unvalid request\n"]) unless user
        "ok"
      end

      # receipes
      #----------------------------------------------------------------------

      get "/recipes/:app/:env/new" do
        new_recipe params[:app], params[:env]
      end

      post "/recipes/:app/:env/create" do
        s = create_recipe params[:app], params[:env], params[:content]
        throw(:halt, [400, "Unvalid request\n"]) unless s
        "ok"
      end

      get "/recipes/:app/:env/show" do
        recipe = recipe_content params[:app], params[:env]
        throw(:halt, [400, "Unvalid request\n"]) unless recipe
        recipe
      end

      post "/recipes/:app/:env/update" do
        update_recipe params[:app], params[:env], params[:content]
        "ok"
      end

      # deploy
      #----------------------------------------------------------------------

      # Deploy an app
      get "/deploy/:app/:env" do
        app = params[:app]
        env = params[:env]
        throw(:halt, [400, "Recipe not found.\n"]) unless recipe_exists? app, env
        stream do |out|
          begin
            deploy app, env, out
          rescue Exception => error
            out.puts "Ops, something went wrong."
            out.puts error
          end
          out.flush
        end
      end

    end
  end

end
