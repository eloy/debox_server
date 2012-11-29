module DeboxServer
  module Apps

    APP_KEY = 'apps'
    def apps_create(app)
      return false if app_exists? app
      redis.sadd(APP_KEY, app)
      redis_save
    end

    def app_exists?(app)
      redis.sismember(APP_KEY, app)
    end

    def apps_list
      redis.smembers APP_KEY
    end

  end
end
