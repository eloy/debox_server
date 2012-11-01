require 'sinatra'
require 'sinatra/namespace'
require 'yaml'
require "debox_server/version"
require "debox_server/utils"
require "debox_server/config"
require "debox_server/users"

# TODO get root without the ../
DEBOX_ROOT = File.join(File.dirname(__FILE__), '../')

module DeboxServer

  module App
    include DeboxServer::Config
    include DeboxServer::Users
  end

  class HTTP < Sinatra::Base


    set :root, DEBOX_ROOT

    require 'rack'
    include DeboxServer::App
    register Sinatra::Namespace
    helpers Sinatra::JSON

    # TODO auto reload please!!
    configure :development do
      use Rack::Reloader
    end

    get "/" do
      "debox #{config_dir}"
    end

    # Return the api_key for the user
    post "/api_key" do
      user = login_user(params[:user], params[:password])
      throw(:halt, [401, "Not authorized\n"]) unless user
      user[:api_key]
    end

    namespace '/api' do

      # Return a list with users in the system
      get '/users' do
        json users_config.keys
      end

      post '/users/create' do
        p "Creating user"
        user = add_user params[:user], params[:password]
        throw(:halt, [400, "Unvalid request\n"]) unless user
        "ok"
      end


      # Deploy an app
      post "/deploy/:app" do
        "Deploing #{params[:app]}"
      end

    end
  end

end
