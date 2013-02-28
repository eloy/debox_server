module Capistrano
  class Configuration

    module Loading
      def load(*args, &block)
        content = args[0][:string]
        @stub = (content == 'mock')
      end
    end

    module Execution
      def find_and_execute_task(path, hooks={})
        return unless @stub
        5.times do |i|
          logger.info "#{i+1} elefantes."
          sleep 0.2
        end
      end
    end
  end
end
