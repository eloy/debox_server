require 'redis'

module DeboxServer
  module RedisDB

    REDIS_URL_PARAM = ENV['REDIS_URL_PARAM'] || 'REDIS_URL'
    REDIS_DEV_DB = 0
    REDIS_TEST_DB = 1

    def self.redis
      @@redis_connection ||= new_redis_connection
    end

    def redis
      return RedisDB::redis
    end

    def self.new_redis_connection
      redis_db = Redis.new redis_connection_params
      redis_db.select redis_db_no
      return redis_db
    end

    def self.redis_db_no
      DeboxServer::environment == :test ? REDIS_TEST_DB : REDIS_DEV_DB
    end

    def self.redis_connection_params
      if url_param = ENV[REDIS_URL_PARAM]
        uri = URI.parse(url_param)
        return { host: uri.host, port: uri.port, password: uri.password}
      end
      return { }
    end

    def self.redis_connected?
      begin
        redis.ping
        return true
      rescue Exception=>error
        puts error
        return false
      end
    end

    def redis_connected?
      DeboxServer::RedisDB::redis_connected?
    end

    def self.check_redis_connection!
      unless redis_connected?
        raise "Can't connect to redis: #{redis_connection_params}"
      end
    end


    def redis_save
      redis.save == 'OK' ? true : false
    end


    # Flush test database
    def self.flush_test_db
      redis.select REDIS_TEST_DB
      redis.flushdb
    end

  end
end
