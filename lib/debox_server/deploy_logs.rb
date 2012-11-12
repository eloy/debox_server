module DeboxServer
  module DeployLogs

    MAX_LOGS_COUNT = 10

    def deployer_logs(app, env)
      range = redis.lrange log_key_name(app, env), 0, MAX_LOGS_COUNT
      range.map do |log|
        JSON.parse log, symbolize_names: true
      end
    end

    def deployer_logs_last(app, env)
      deployer_logs_at app, env, 0
    end

    def deployer_logs_at(app, env, index)
      JSON.parse redis.lindex(log_key_name(app, env), index), symbolize_names: true
    end

    def deployer_logs_count(app, env)
      redis.llen log_key_name(app, env)
    end

    def deployer_logs_destroy(app, env)
      redis.del log_key_name(app, env)
    end

    def log_key_name(app, env)
      "logger_#{app}_#{env}"
    end

    def save_deploy_log(app, env, task, out, config)
      log_data = {
        app: app,
        env: env,
        task: task,
        time: out.time,
        success: out.success,
        status: out.success ? "success" : "error",
        log: out.buffer || '** EMPTY BUFFER ** ',
        error: out.error || '',
        config: config
      }
      redis.lpush log_key_name(app, env), log_data.to_json

      # Remove last logs
      if deployer_logs_count(app, env) > MAX_LOGS_COUNT
        redis.ltrim log_key_name(app, env), 0, MAX_LOGS_COUNT - 1
      end
      redis_save
    end
  end

  # Output multiplexer
  class OutputMultiplexer
    attr_reader :buffer, :time, :result, :success, :error

    def initialize
      @time = DateTime.now
      @buffer = ''
      @listeners = []
      @channel = EM::Channel.new
    end

    def puts(msg)
      @buffer += msg
      @channel.push msg
      DeboxServer::log.debug msg
    end

    def result=(result)
      @result = result
      @success = true
    end

    def error=(error)
      @error = error || 'Error'
      @success = false
    end

    # Subscribe an output strem
    def subscribe(out)
      @channel.subscribe {|msg| out.puts msg}
    end

    def unsubscribe(sid)
      @channel.unsubscribe sid
    end

    # Override some methods
    def tty?
      false
    end
  end

end
