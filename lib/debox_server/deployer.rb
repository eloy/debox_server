require 'capistrano'
require 'capistrano/cli'

module DeboxServer
  module Deployer
    include DeboxServer::Recipes
    include DeboxServer::RedisDB

    @@deploy_queues = { }
    @@runnung_jobs = { }

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

    def schedule_job(job)
      DeboxServer::Deployer::add_job_to_queue job
    end

    def self.next_job_id
      REDIS.incr(:next_job_id)
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
  end
end
