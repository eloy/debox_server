require 'json'
require 'fileutils'
require 'erb'

require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/namespace'
require "sinatra/streaming"

require "debox_server/version"
require "debox_server/logger"
require "debox_server/config"
require "debox_server/utils"
require 'debox_server/redis'
require "debox_server/ssh_keys"
require "debox_server/apps"
require "debox_server/users"
require "debox_server/recipes"
require "debox_server/deploy_logs"
require "debox_server/job"
require "debox_server/deployer"
require "debox_server/basic_auth"
require "debox_server/view_helpers"

# TODO get root without the ../
DEBOX_ROOT = File.join(File.dirname(__FILE__), '../')

module DeboxServer

  module App
    include DeboxServer::Utils
    include DeboxServer::Config
    include DeboxServer::RedisDB
    include DeboxServer::SshKeys
    include DeboxServer::Apps
    include DeboxServer::Users
    include DeboxServer::Recipes
    include DeboxServer::DeployLogs
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
    include DeboxServer::ViewHelpers

    register Sinatra::Namespace
    helpers Sinatra::Streaming
    helpers Sinatra::JSON

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

      # Users
      #----------------------------------------------------------------------

      # Return a list with users in the system
      get '/users' do
        json users_config.keys
      end

      post '/users/create' do
        user = add_user params[:user], params[:password]
        throw(:halt, [400, "Unvalid request\n"]) unless user
        "ok"
      end

      post '/users/destroy' do
        throw(:halt, [400, "Unvalid request\n"]) unless params[:user]
        users_destroy params[:user]
        "ok"
      end

      # apps
      #----------------------------------------------------------------------

      get '/apps' do
        json apps_list
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

      post "/recipes/:app/:env/destroy" do
        recipes_destroy params[:app], params[:env]
        "ok"
      end

      get "/recipes/:app" do
        json recipes_list(params[:app])
      end

      # deploy
      #----------------------------------------------------------------------

      # Deploy an app
      # Deprecated
      get "/deploy/:app/:env/?:task?" do
        app = params[:app]
        env = params[:env]
        task = params[:task] || 'deploy'
        throw(:halt, [400, "Recipe not found.\n"]) unless recipe_exists? app, env
        job = Job.new(app, env, task)
        schedule_job(job)
        json job_id: job.id , app: app, env: env, task: task
      end

      # Deploy an app
      get "/cap/:app/?:env?" do
        task = params[:task] || 'deploy'
        job = Job.new(current_app, current_env, task)
        schedule_job(job)
        json job_id: job.id , app: current_app, env: current_env, task: task
      end

      # logs
      #----------------------------------------------------------------------

      get "/live_log/:app/?:env?/?:job_id?" do
        stream(:keep_open) do |out|

          job = DeboxServer::Deployer::running_job current_app, current_env
          if job && (params[:job_id].nil? || params[:job_id] == job.id)
            out.puts "Living log for #{job.id}:"
            out.puts job.buffer # Show current buffer
            sid = job.subscribe out
            out.callback { job.unsubscribe(out, sid) }
            out.errback { job.unsubscribe(out, sid) }
          else
            out.puts "Not running"
            out.flush
            out.close
          end
        end
      end

      get "/logs/:app/?:env?" do
        logs = deployer_logs current_app, current_env
        out = logs.map do |l|
          { status: l[:status], task: l[:task], time: l[:time], error: l[:error] }
        end
        json out
      end

      get "/logs/:app/:env/:index" do
        index = params[:index] == 'last' ? 0 : params[:index]
        log = deployer_logs_at current_app, current_env, index
        throw(:halt, [400, "Log not found.\n"]) unless log
        log[:log]
      end

      # SSH keys
      #----------------------------------------------------------------------
      get "/public_key" do
        ssh_public_key || "SSH keys not found"
      end
    end
  end

end
