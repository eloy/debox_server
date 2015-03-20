# Async response for Thin and other EventMachine servers
# Inspired on this post: http://polycrystal.org/2012/04/15/asynchronous_responses_in_rack.html
require 'eventmachine'

module ThrowAsync

  def chunk(content)
    body.push content
  end

  def close
    @before_close_callback.call if @before_close_callback
    # calls Thin's callback which closes the request
    body.succeed
  end

  def on_error(&block)
    body.errback block
  end

  def on_success(&block)
    body.callback block
  end

  def before_close(&block)
    @before_close_callback = block
  end

  def after_close(&block)
    on_error block
    on_success block
  end

  def async(&block)
    # Send the reply headers
    env['async.callback'].call [200, {'Content-Type' => content_type}, body]

    # Call the given block
    block.call
    throw :async
  end

  private

  # A deferrable object for the body.
  class DeferrableBody
    include EventMachine::Deferrable

    def push(content)
      @body_callback.call content
    end

    def each(&blok)
      @body_callback = blok
    end
  end


  def body
    @deferable_body ||= DeferrableBody.new
  end

  def content_type
    'text/plain'
  end
end



module ThrowEventSource
  include ThrowAsync

  def chunk(content)
    # Send content line by line if include
    # a \n char
    if content.include? "\n"
      content.split("\n").each do |line|
        body.push "data: #{line}\n"
      end
    else
      body.push "data: #{content}\n"
    end

    body.push "\n"
  end


  def close
    @before_close_callback.call if @before_close_callback
    @timer.cancel if @timer
    body.push "data: job finished\n"
    body.push "event: finish\n"
    body.push "\n"
    body.succeed
  end

  def keep_alive(timeout=5)
    @timer = EM::PeriodicTimer.new(timeout) do
      # chunk({connections: ActiveRecord::Base.connection_pool.connections.count}.to_json
      body.push ":\n"
    end
  end


  private

  def content_type
    'text/event-stream'
  end

end
