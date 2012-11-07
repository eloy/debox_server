require 'capistrano'
require 'capistrano/cli'

module DeboxServer
  module Deployer
    include DeboxServer::Recipes

    def deploy(std_output, app, env, task)
      out = DeboxServer::OutputMultiplexer.new std_output

      config = new_capistrano_config out
      # Load the recipe content
      begin
        config.load string: recipe_content(app, env)
        result = config.find_and_execute_task(task, before: :start, after: :finish)
        out.result = result
      rescue Capistrano::CommandError=> error
        out.error = error
      end

      save_deploy_log app, env, task, out
      return result
    end

    private

    def new_capistrano_config(out)
      config = Capistrano::Configuration.new output: out
      config.logger.level = Capistrano::Logger::DEBUG
      return config
    end

  end
end
