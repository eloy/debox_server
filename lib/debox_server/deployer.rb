require 'capistrano'
require 'capistrano/cli'

module DeboxServer
  module Deployer
    include DeboxServer::Recipes

    @@deploy_queues = { }
    @@runnung_jobs = { }
    @@deploy_counter = 0

    def self.job_running?(app, env, job_id)
      name = queue_name(app, env)
      return false unless @@runnung_jobs.has_key? name
      @@runnung_jobs[name].id == job_id
    end

    # Return the job running just now
    def self.running_job(app, env)
      name = queue_name(app, env)
      return false unless @@runnung_jobs.has_key? name
      @@runnung_jobs[name]
    end

    def queue_empty?(app, env)
      @@runnung_jobs.has_key? queue_name(app, env)
    end

    def schedule_deploy_job(app, env, task)
      job = DeployJob.new(app, env, task)
      DeboxServer::Deployer::add_job_to_queue job
      return job
    end

    def self.next_deploy_id
      @@deploy_counter += 1
    end

    def self.add_job_to_queue(job)
      EM::next_tick { deploy_queue(job.app, job.env).push job }
    end

    def self.deploy_queue(app, env)
      @@deploy_queues[queue_name(app, env)] ||= deploy_queue_create
    end

    def self.queue_name(app, env)
      "#{app}_#{env}".to_sym
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
          # Pop next job or wait for other
          queue.pop(&processor)
        end

        EM::defer proc { job.deploy }, callback
      }

      # Pop first element for start the process
      queue.pop(&processor)
      return queue
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
        @running = false
      end

      def deploy
        @running = true
        config = new_capistrano_config @stdout

        begin
          # Load the recipe content
          config.load string: @recipe

          # # Don't ask for real revision on localhost
          # # http://thread.gmane.org/gmane.comp.lang.ruby.capistrano.general/4384
          # config.set(:real_revision) {
          #   source.query_revision(revision) { |cmd|
          #     capture(cmd) }
          # }

          DeboxServer.log.info "Deploying from git: #{config[:repository]} #{config[:branch]}, #{config[:real_revision]}"
          result = config.find_and_execute_task(task, before: :start, after: :finish)
          @stdout.result = result
        rescue Exception => error
          DeboxServer::log.info "Task #{self.id} finished with error #{error}"
          @stdout.error = error
        end
        @running = false

        capistrano_config = {
          revision: config[:real_revision],
          repository: config[:repository],
          branch: config[:branch],
        }

        save_deploy_log app, env, task, @stdout, capistrano_config
        return self
      end

      def buffer
        @stdout.buffer
      end

      def running?
        @running
      end

      def subscribe(out)
        @stdout.subscribe(out)
      end

      def unsubscribe(sid)
        @stdout.unsubscribe(sid)
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
