module DeboxServer
  module Config

    CONFIG_FILE = "debox_server.conf"
    RECEIPES_DIR= "receipes.d"


    def config_dir
      ENV['DEBOX_SERVER_CONFIG'] || File.join(settings.root, 'config')
    end

  end
end
