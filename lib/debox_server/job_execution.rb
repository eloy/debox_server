require "debox_server/output_multiplexer"

module DeboxServer

  # Deploy job
  #----------------------------------------------------------------------

  module JobExecution

    def start
      execute_task
      update_job_status
      unsubscribe_all
      trigger_on_finish
      return self
    end

    # Current job output
    def buffer
      stdout.buffer
    end

    def running?
      @running ||= false
    end

    def finished?
      @finished ||= false
    end

    # callbacks
    #----------------------------------------------------------------------

    def subscribed_ids
      @subscribed_ids ||= []
    end

    def subscribe(&block)
      sid = stdout.channel.subscribe block
      subscribed_ids << sid
    end

    def unsubscribe(sid)
      stdout.channel.unsubscribe sid
    end

    # Define callback to be called when the job ends
    def on_finish(&block)
      on_finish_callbacks << block
    end

    private

    # Load the recipe and execute the task
    def execute_task
      @running = true
      self.start_time = DateTime.now
      begin

        # Load the recipe content
        capistrano.load string: self.recipe.content

        DeboxServer.log.info "Deploying from git: #{capistrano[:repository]} #{capistrano[:branch]}, #{capistrano[:real_revision]}"
        result = capistrano.find_and_execute_task(task, before: :start, after: :finish)
        stdout.result = result

      rescue Capistrano::CommandError => error
        DeboxServer::log.warn "Task #{self.id} finished with error #{error}"
        stdout.error = error
        return false
      ensure
      end
    end

    def update_job_status
      self.end_time = DateTime.now
      self.log = stdout.buffer || "** EMPTY BUFFER **"
      self.success = stdout.success || false
      self.error = stdout.error
      self.config = { } #capistrano.to_json
      self.save
    end

    def unsubscribe_all
      subscribed_ids.each do |sid|
        stdout.channel.unsubscribe sid
      end
    end

    def trigger_on_finish
      on_finish_callbacks.each do |callback|
        callback.call
      end
    end

    def on_finish_callbacks
      @on_finish_callbacks ||= []
    end

    def capistrano
      @capistrano_config ||= new_capistrano_config stdout
    end

    def stdout
      @multiplexed_stdout ||= DeboxServer::OutputMultiplexer.new
    end

    # Return an empty capistrano config
    def new_capistrano_config(out)
      config = Capistrano::Configuration.new output: out
      config.logger.level = Capistrano::Logger::DEBUG
      return config
    end
  end

end
