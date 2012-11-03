require 'redis'

module DeboxServer
  module RedisDB

    REDIS_URL_PARAM = ENV['REDIS_URL_PARAM'] || 'REDIS_URL'
    def self.new_redis_server
      if url_param = ENV[REDIS_URL_PARAM]
        uri = URI.parse(url_param)
        params = { host: uri.host, port: uri.port, password: uri.password}
      end

      redis_db = Redis.new(params || {})
      redis_db.select redis_db_no
      return redis_db
    end

    def self.redis_db_no
      DeboxServer::environment == :test ? 1 : 0
    end

    def redis
      # REDIS.select DeboxServer::RedisDB::redis_db_no
      return REDIS
    end

  end
end

REDIS = DeboxServer::RedisDB.new_redis_server
