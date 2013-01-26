require 'capistrano'
require 'capistrano/cli'

module DeboxServer

  def job_queue
    DeboxServer::job_queue
  end

  def self.job_queue
    @@job_queue ||= JobQueue.new
  end

  class JobQueue

    include DeboxServer::Recipes
    include DeboxServer::RedisDB
    include DeboxServer::JobNotifier

    def queues
      @queues ||= { }
    end

    def running
      @running ||= {}
    end

    def queue_empty?(app, env)
      running.has_key? queue_name(app, env)
    end

    def job_running?(app, env, job_id)
      name = queue_name(app, env)
      return false unless running.has_key? name
      running[name].id == job_id
    end

    # Return the job running just now
    def find(app, env)
      name = queue_name(app, env)
      return false unless running.has_key? name
      running[name]
    end

    # Add a job to the queue
    def add(job)
      EM::next_tick { deploy_queue(job.app, job.env).push job }
    end

    # Generate id for the new job
    def next_job_id
      RedisDB::redis.incr(:next_job_id)
    end

    def deploy_queue(app, env)
      queues[queue_name(app, env)] ||= deploy_queue_create
    end

    def queue_name(app, env)
      "#{app}_#{env}".to_sym
    end

    # Create a new EM::Queue and start the pop process
    def deploy_queue_create
      queue = EM::Queue.new
      processor = proc { |job|
        name = queue_name job.app, job.env
        running[name] = job
        DeboxServer::log.info "Starting job #{job.id}"

        callback = proc do |job|
          running.delete name
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
