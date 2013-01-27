require 'capistrano'
require 'capistrano/cli'

module DeboxServer

  def jobs_queue
    DeboxServer::jobs_queue
  end

  def self.jobs_queue
    @@jobs_queue ||= JobsQueue.new
  end

  class JobsQueue

    include DeboxServer::Recipes
    include DeboxServer::RedisDB
    include DeboxServer::Logger


    def jobs
      @queued_jobs ||= []
    end

    # Return the job running just now
    def find(id)
      jobs.select {|job| job.id == id}.first
    end

    # Add a job to the queue
    def add(job)
      jobs.push job
      notifier.added job
      EM::next_tick do
        queue(job.app, job.env).push job
      end
    end

    # Generate id for the new job
    def next_job_id
      redis.incr(:next_job_id)
    end

    private

    def queue(app, env)
      queues[queue_name(app, env)] ||= new_queue
    end

    def queue_name(app, env)
      "#{app}_#{env}".to_sym
    end

    def notifier
      @notifier ||= JobNotifier.new
    end

    def queues
      @queues ||= { }
    end


    # Create a new EM::Queue and start the pop process
    def new_queue
      queue = EM::Queue.new
      processor = proc { |job|
        name = queue_name job.app, job.env
        log.debug "Starting job #{job.id}"

        callback = proc do |job|
          log.debug "Job #{job.id} finished"
          notifier.stoped job
          jobs.delete job
          # Pop next job or wait for other
          queue.pop(&processor)
        end

        notifier.started job
        EM::defer proc { job.start }, callback
      }

      # Pop first element for start the process
      queue.pop(&processor)
      return queue
    end
  end
end
