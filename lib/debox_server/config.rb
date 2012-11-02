module DeboxServer
  module Config

    def config_dir
      ENV['DEBOX_SERVER_CONFIG'] || File.join(settings.root, 'config')
    end

  end
end
