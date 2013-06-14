module DeboxServer
  module Config

    def self.debox_root
      ENV['DEBOX_ROOT']
    end

    def debox_root
      Config.debox_root
    end

    def config_dir
      Config::config_dir
    end

    def self.config_dir
      ENV['DEBOX_SERVER_CONFIG'] || File.join(Config.debox_root, 'config')
    end

    def db_conf
      Config::db_conf
    end

    def self.db_conf
      db_conf_file = File.join Config::config_dir, 'database.yml'
      YAML.load(File.read(db_conf_file))
    end

  end
end
