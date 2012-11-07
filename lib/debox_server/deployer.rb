require 'capistrano'
require 'capistrano/cli'

module DeboxServer
  module Deployer
    include DeboxServer::Recipes

    def schedule_deploy_job(app, env, task)
      job = DeployJob.new(app, env, task)
      DeboxServer::Deployer::add_job_to_queue job
      return job
    end

    # Deploy Queue
    #----------------------------------------------------------------------

    # Class var for store the queues for each app and enviroment
    @@deploy_queues = { }
    @@runnung_jobs = { }
    @@deploy_counter = 0

    def self.next_deploy_id
      @@deploy_counter += 1
    end

    def self.add_job_to_queue(job)
      EM::next_tick { deploy_queue(job.app, job.env).push job }
    end

    def self.deploy_queue(app, env)
      @@deploy_queues[queue_name(app, env)] ||= deploy_queue_create
    end

    # Create a new EM::Queue and start the pop process
    def self.deploy_queue_create
      queue = EM::Queue.new
      processor = proc { |job|
        name = queue_name job.app, job.env
        @@runnung_jobs[name] = job
        DeboxServer::log.info "Starting job #{job.id}"

        callback = proc do |job|
          @@runnung_jobs.delete name
          DeboxServer::log.info "Job #{job.id} finished"
          queue.pop(&processor)
        end

        EM::defer proc { job.deploy }, callback
      }

      # Pop first element for start the process
      queue.pop(&processor)
      return queue
    end

    def self.queue_name(app, env)
      "#{app}_#{env}".to_sym
    end

    # Deploy job
    #----------------------------------------------------------------------

    class DeployJob
      include DeboxServer::RedisDB
      include DeboxServer::Recipes
      include DeboxServer::DeployLogs

      attr_reader :id, :app, :env, :task

      def initialize(app, env, task)
        @id = DeboxServer::Deployer::next_deploy_id
        @app = app
        @env = env
        @task = task
        @recipe = recipe_content app, env
        @stdout = DeboxServer::OutputMultiplexer.new

      end

      def deploy
        config = new_capistrano_config @stdout
        # Load the recipe content
        begin
          config.load string: @recipe
          result = config.find_and_execute_task(task, before: :start, after: :finish)
          @stdout.result = result
        rescue Exception => error
          @stdout.error = error
        end

        save_deploy_log app, env, task, @stdout
        return self
      end

      private

      # Return an empty capistrano config
      def new_capistrano_config(out)
        config = Capistrano::Configuration.new output: out
        config.logger.level = Capistrano::Logger::DEBUG
        return config
      end
    end

  end
end
