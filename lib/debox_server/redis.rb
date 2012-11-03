require 'redis'

module DeboxServer
  module RedisDB

    def self.new_redis_server
      redis_db = Redis.new
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
