module DeboxServer
  # module DeployLogs

  #   MAX_LOGS_COUNT = 15

  #   def deployer_logs(app, env)
  #     range = redis.lrange log_key_name(app, env), 0, MAX_LOGS_COUNT
  #     range.map do |log|
  #       JSON.parse log, symbolize_names: true
  #     end
  #   end

  #   def deployer_logs_last(app, env)
  #     deployer_logs_at app, env, 0
  #   end

  #   def deployer_logs_at(app, env, index)
  #     log = redis.lindex(log_key_name(app, env), index)
  #     JSON.parse log, symbolize_names: true if log
  #   end

  #   def deployer_logs_count(app, env)
  #     redis.llen log_key_name(app, env)
  #   end

  #   def deployer_logs_destroy(app, env)
  #     redis.del log_key_name(app, env)
  #   end

  #   def log_key_name(app, env)
  #     "logger_#{app}_#{env}"
  #   end
  # end


  # Output multiplexer
  class OutputMultiplexer
    attr_reader :buffer, :time, :result, :success, :error

    def initialize
      @buffer = ''
      @listeners = []
    end

    def channel
      @em_channel ||= EM::Channel.new
    end

    def puts(msg)
      @buffer += msg
      channel.push msg
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

    # Override some methods
    def tty?
      false
    end
  end

end
