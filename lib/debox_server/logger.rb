require 'log4r'
module DeboxServer
  module Logger
    include Log4r

    def log
      DeboxServer::log
    end

    def self.log
      @@logger ||= new_logger
    end


    private
    def self.new_logger
      mylog = Log4r::Logger.new 'debox_server'
      mylog.outputters = Log4r::Outputter.stdout
      return mylog
    end
  end

  def self.log
    Logger::log
  end


end
