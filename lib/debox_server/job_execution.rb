require "debox_server/output_multiplexer"

module DeboxServer

  # Deploy job
  #----------------------------------------------------------------------

  module JobExecution

    def start
      @thread = Thread.current
      execute_task
      update_job_status
      unsubscribe_all
      trigger_on_finish
      return self
    end

    # TODO: Refactor?
    def kill!
      @thread.kill
      self.error = "Stoped by user."
      update_job_status
      unsubscribe_all
      trigger_on_finish
      @queue_callback.call(self)
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


    protected

    def set_started!
      self.update_attributes start_time: DateTime.now, config: extract_capistrano_config
    end

    # Return a hash with configs from capistrano
    def extract_capistrano_config
      config = {}
      config_keys = [:repository, :branch, :real_revision]
      config_keys.each do |key|
        config[key] = self.capistrano[key]
      end
      return config
    end

    # Load the recipe and execute the task
    def execute_task
      @running = true

      begin
        capistrano.load_paths << File.join(Config.debox_root, 'capistrano')

        # Load the recipe content and extract config to make it available to status
        capistrano.load string: self.recipe.content
        set_started!

        DeboxServer.log.info "Deploying from git: #{capistrano[:repository]} #{capistrano[:branch]}, #{capistrano[:real_revision]}"
        result = capistrano.find_and_execute_task(task, before: :start, after: :finish)
        stdout.result = result

      rescue Exception => error
        DeboxServer::log.warn "Task #{self.id} finished with error #{error}"
        stdout.puts "Task finished with error: #{error}"
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
      # Save and quickly return the connection to the pool
      ActiveRecord::Base.connection_pool.with_connection { self.save }
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
