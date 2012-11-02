require 'capistrano'
require 'capistrano/cli'

module DeboxServer
  module Deployer
    include DeboxServer::Recipes

    def deploy(app, env, out)
      config = new_capistrano_config out
      # Load the recipe file
      recipe = recipe_file_name app, env
      config.load recipe
      config.find_and_execute_task('deploy', before: :start, after: :finish)
    end

    private

    def new_capistrano_config(out)
      config = Capistrano::Configuration.new output: out
      # config.logger.level = Capistrano::Logger::IMPORTANT
      config.logger.level = Capistrano::Logger::INFO
      # config.logger.level = Capistrano::Logger::DEBUG

      return config
    end

  end
end