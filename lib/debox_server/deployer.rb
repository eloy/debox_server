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
        @streams = []
      end

      def deploy
        execute_task
        save_log
        unsubscribe_all
        return self
      end

      # Load the recipe and execute the task
      def execute_task
        @running = true
        begin
          @config = new_capistrano_config @stdout
          # Load the recipe content
          @config.load string: @recipe

          DeboxServer.log.info "Deploying from git: #{@config[:repository]} #{@config[:branch]}, #{@config[:real_revision]}"
          result = @config.find_and_execute_task(task, before: :start, after: :finish)
          @stdout.result = result

        rescue Exception => error
          DeboxServer::log.warn "Task #{self.id} finished with error #{error}"
          @stdout.error = error
          return false
        ensure
          @running = false
        end
      end

      # Save capistrano logs in redis
      def save_log
        begin
          capistrano_config = {
            revision: @config[:real_revision],
            repository: @config[:repository],
            branch: @config[:branch],
          }

          save_deploy_log app, env, task, @stdout, capistrano_config
        rescue Exception => error
          DeboxServer::log.warn "Error saving logs from #{self.id}: #{error}"
        end

      end


      def buffer
        @stdout.buffer
      end

      def running?
        @running
      end

      def subscribe(out)
        sid = @stdout.subscribe(out)
        @streams << { out: out, sid: sid }
      end

      def unsubscribe(out, sid)
        stream = @streams.select{ |s| s[:sid] == sid }
        return unless stream
        @streams.delete stream
        @stdout.unsubscribe(sid)
      end

      def unsubscribe_all
        @streams.each do |s|
          @stdout.unsubscribe s[:sid]
          s[:out].close
        end
        @streams = []
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
