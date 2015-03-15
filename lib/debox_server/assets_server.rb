module DeboxServer
  class AssetsServer

    def initialize(options)
      @static = ::Rack::Static.new(lambda { [404, {}, []] }, options)
    end

    def call(env)
      orig_path = env['PATH_INFO']

      # there's probably a better way to do this
      if orig_path.starts_with?('/v1/')
        return DeboxServer::DeboxAPI.call(env)
      end

      if orig_path.starts_with?('/assets')
        env['PATH_INFO'] = env['PATH_INFO'][7..-1] # 7 => sizeof /assets
        return sprokets.call(env)
      end


      if orig_path == "/"
        env['PATH_INFO'] = "/index.html"
      end

      resp = @static.call(env)
    end

    def sprokets
      @sprokets ||= AssetsServer.build_spockets(ENV['DEBOX_ROOT'])
    end

    def self.build_spockets(root)
      sprokets = Sprockets::Environment.new
      sprokets.append_path File.join(root, 'ui', 'coffee')
      sprokets.append_path File.join(root, 'ui', 'sass')
      sprokets.append_path File.join(root, 'ui', 'vendor', 'js')
      sprokets.append_path File.join(root, 'ui', 'vendor', 'css')
      return sprokets
    end
  end
end
