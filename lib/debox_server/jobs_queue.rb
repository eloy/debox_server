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
        queue(job.recipe).push job
      end
    end

    # Generate id for the new job
    def next_job_id
      redis.incr(:next_job_id)
    end

    def channel
      notifier.channel
    end

    def notifier
      @notifier ||= JobNotifier.new
    end

    def status
      { queued_jobs: jobs, queues: queues }
    end

    private

    def queue(recipe)
      queues[queue_name(recipe)] ||= new_queue
    end

    def queue_name(recipe)
      "#{recipe.app.name}_#{recipe.name}".to_sym
    end

    def queues
      @queues ||= { }
    end


    # Create a new EM::Queue and start the pop process
    def new_queue
      queue = EM::Queue.new
      processor = proc { |job|
        log.debug "Starting job #{job.id}"

        job.queue_callback = proc do |job|
          log.debug "Job #{job.id} finished"
          notifier.finished job
          jobs.delete job # Remove job from jobs queue
          # Pop next job or wait for other
          queue.pop(&processor)
        end

        notifier.started job

        # Subscribe to stdout for send notifications
        job.subscribe do |msg|
          notifier.stdout job, data: msg
        end
        EM::defer proc { job.start }, job.queue_callback
      }

      # Pop first element for start the process
      queue.pop(&processor)
      return queue
    end
  end
end
