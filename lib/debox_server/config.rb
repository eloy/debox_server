module DeboxServer
  module Config

    def config_dir
      ENV['DEBOX_SERVER_CONFIG'] || File.join(DEBOX_ROOT, 'config')
    end

  end
end
