# Users configuration
module DeboxServer
  module Users
    include DeboxServer::Utils
    CONFIG_FILE = 'users.conf'

    def find_user(email)
      users_config[email]
    end

    # Return a valid user with the given credentials or false if not found
    def login_user(email, clean_password)
      user_data = users_config[email]
      return false unless user_data
      password = user_data[:password]
      return false unless password == hash_str(clean_password)
      return user_data
    end

    def login_api_key(email, api_key)
      user_data = users_config[email]
      return false unless user_data && user_data[:api_key] == api_key
      return user_data
    end


    def add_user(email, password)
      users = users_config
      users[email] = { password: hash_str(password), api_key: generate_uuid }
      save_users users
      return users[email]
    end

    # Return the content of the users config file
    def users_config
      return { } unless File.exists? users_config_file
      YAML.load_file users_config_file
    end

    private

    def users_config_file
      File.join config_dir, CONFIG_FILE
    end

    def save_users(users)
      f = File.open(users_config_file, 'w')
      f.write(users.to_yaml)
      f.close
    end
  end
end
