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

    def users_find!(email)
      redis.hget('users', email)
    end

    def find_user(email)
      user = users_find! email
      return OpenStruct.new JSON.parse(user) if user
    end

    def add_user(email, password, opt={})
      api_key = opt[:api_key] || generate_uuid
      user = { email: email, password: hash_str(password), api_key: api_key }
      user[:admin] = true if opt[:admin]
      redis.hsetnx 'users', email, user.to_json
      redis.save
      return OpenStruct.new user
    end

    def users_make_admin!(email)
      user_data = users_find!(email)
      return false unless user_data
      user = JSON.parse user_data
      user['admin'] = true
      redis.hset 'users', email, user.to_json
    end

    def users_remove_admin!(email)
      user_data = users_find!(email)
      return false unless user_data
      user = JSON.parse user_data
      user['admin'] = false
      redis.hset 'users', email, user.to_json
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
