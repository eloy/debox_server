module DeboxServer

  # Deploy job
  #----------------------------------------------------------------------

  class Job
    include DeboxServer::RedisDB
    include DeboxServer::Recipes
    include DeboxServer::DeployLogs

    attr_reader :id, :app, :env, :task

    def initialize(app, env, task)
      @id = DeboxServer::jobs_queue.next_job_id
      @app = app
      @env = env
      @task = task
      @recipe = recipe_content app, env
      @running = false
      @finished = false
      @subscribed_ids = []
    end

    def start
      execute_task
      save_log
      unsubscribe_all
      trigger_on_finish
      return self
    end

    # Load the recipe and execute the task
    def execute_task
      @running = true
      @start_time = DateTime.now
      begin

        # Load the recipe content
        capistrano.load string: @recipe

        DeboxServer.log.info "Deploying from git: #{capistrano[:repository]} #{capistrano[:branch]}, #{capistrano[:real_revision]}"
        result = capistrano.find_and_execute_task(task, before: :start, after: :finish)
        stdout.result = result

      rescue Exception => error
        DeboxServer::log.warn "Task #{self.id} finished with error #{error}"
        stdout.error = error
        return false
      ensure
        @running = false
        @finished = true
        @end_time = DateTime.now
      end
    end

    # Save capistrano logs in redis
    def save_log
      begin
        job_log = info
        job_log[:log] = stdout.buffer || "** EMPTY BUFFER **"
        redis.lpush log_key_name(app, env), job_log.to_json

        # Remove last logs
        if deployer_logs_count(app, env) > MAX_LOGS_COUNT
          redis.ltrim log_key_name(app, env), 0, MAX_LOGS_COUNT - 1
        end
        redis_save
      rescue Exception => error
        DeboxServer::log.error "Error saving logs from #{self.id}: #{error}"
      end
    end

    # Return info about the job
    # Used for generate the log
    def info
      { job_id: self.id,
        app: app,
        env: env,
        task: task,
        start_time: @start_time,
        end_time: @end_time,
        running: @running,
        success: stdout.success || false,
        status: stdout.success ? "success" : "error",
        error: stdout.error || '',
        config: {
          revision: capistrano[:real_revision],
          repository: capistrano[:repository],
          branch: capistrano[:branch],
        }
      }
    end

    # Current job output
    def buffer
      stdout.buffer
    end

    def running?
      @running
    end

    def finished?
      @finished
    end

    # callbacks
    #----------------------------------------------------------------------


    def subscribe(&block)
      sid = stdout.channel.subscribe block
      @subscribed_ids << sid
    end

    def unsubscribe(sid)
      stdout.channel.unsubscribe sid
    end

    def unsubscribe_all
      @subscribed_ids.each do |sid|
        stdout.channel.unsubscribe sid
      end
    end

    def on_finish(&block)
      on_finish_callbacks << block
    end

    private

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
