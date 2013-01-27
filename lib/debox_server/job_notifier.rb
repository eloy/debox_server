module DeboxServer
  class JobNotifier

    def channel
      @channel ||= EM::Channel.new
    end

    private

    def method_missing(method_name, *args)
      send_notification method_name, args[0]
    end

    def send_notification(notification, job)
      msg = {notification: notification, job: job.info}.to_json
      channel.push msg
    end

  end
end
