# Users configuration
module DeboxServer
  module Users
    include DeboxServer::Utils
    include DeboxServer::Config

    # Return a valid user with the given credentials or false if not found
    def login_user(email, clean_password)
      user_data = find_user email
      return false unless user_data
      password = user_data.password
      return false unless password == hash_str(clean_password)
      return user_data
    end

    def login_api_key(email, api_key)
      user_data = find_user(email)
      return false unless user_data && user_data.api_key == api_key
      return user_data
    end

    def find_user(email)
      user = redis.hget('users', email)
      if user
        OpenStruct.new JSON.parse(user)
      else
        false
      end
    end

    def add_user(email, password)
      user = { email: email, password: hash_str(password), api_key: generate_uuid }
      redis.hsetnx 'users', email, user.to_json
      redis.save
      return OpenStruct.new user
    end

    def users_destroy(email)
      redis.hdel 'users', email
      redis_save
    end

    def users_list
      users_config.keys
    end


    # Return the content of the users config file
    def users_config
      redis.hgetall('users') || {}
    end

  end
end
