module DeboxServer
  class JobNotifier
    include DeboxServer::Logger
    def channel
      @channel ||= EM::Channel.new
    end

    private

    def method_missing(method_name, *args)
      job = args[0]
      opt = args[1] || { }
      send_notification method_name, job, opt
    end

    def send_notification(notification, job, opt={ })
      msg = {notification: notification, job: job.info}
      msg.merge! opt
      channel.push msg.to_json
    end

  end
end
