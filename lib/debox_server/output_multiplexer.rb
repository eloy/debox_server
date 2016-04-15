module DeboxServer

  # Output multiplexer
  #
  # Used as output for capistrano
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
      @buffer += msg.encode(Encoding.find('UTF-8'), {invalid: :replace, undef: :replace, replace: ''})
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
