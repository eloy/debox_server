require 'log4r'
module DeboxServer
  include Log4r

  def self.log
    @@logger ||= new_logger
  end

  def log
    DeboxServer::log
  end

  private
  def self.new_logger
    mylog = Logger.new 'debox_server'
    mylog.outputters = Outputter.stdout
    return mylog
  end
end
