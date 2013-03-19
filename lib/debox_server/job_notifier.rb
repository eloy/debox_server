module DeboxServer
  class JobNotifier
    include DeboxServer::Logger

    def channel
      @channel ||= EM::Channel.new
    end

    private

    def send_notification(notification, job, opt={ })
      log.info "Notification: #{notification}"
      msg = {notification: notification, job: job}
      msg.merge! opt
      channel.push msg.to_json
    end

    def self.notifications(*args)
      args.each do |notification|
        define_method notification do |*args|
          job = args[0]
          opt = args[1] || { }
          send_notification notification, job, opt
        end
      end
    end

    notifications :started, :stdout, :added

  end
end
