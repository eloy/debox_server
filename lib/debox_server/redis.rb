require 'redis'

module DeboxServer
  module RedisDB

    REDIS_URL_PARAM = 'REDIS_URL'

    def self.new_redis_server
      redis_db = Redis.new connection_params
      redis_db.select redis_db_no
      return redis_db
    end

    def self.connection_params
      if url_param = ENV[REDIS_URL_PARAM]
        uri = URI.parse(url_param)
        return { host: uri.host, port: uri.port, password: uri.password }
      end
      return { }
    end

    def self.redis_db_no
      DeboxServer::environment == :test ? 1 : 0
    end

    def redis
      return REDIS
    end

    def redis_save
      redis.save == 'OK' ? true : false
    end

  end
end

REDIS = DeboxServer::RedisDB.new_redis_server
