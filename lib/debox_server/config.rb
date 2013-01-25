module DeboxServer
  module Config

    def config_dir
      Config::config_dir
    end

    def self.config_dir
      ENV['DEBOX_SERVER_CONFIG'] || File.join(DEBOX_ROOT, 'config')
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
