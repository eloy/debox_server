# Users configuration
module DeboxServer
  module Users
    include DeboxServer::Utils
    include DeboxServer::Config

    # Return a valid user with the given credentials or false if not found
    def login_user(email, clean_password)
      user_data = User.find_by_email email
      return false unless user_data
      password = user_data.password
      return false unless password == hash_str(clean_password)
      return user_data
    end

    def login_api_key(email, api_key)
      user_data = User.find_by_email email
      return false unless user_data && user_data.api_key == api_key
      return user_data
    end

    def add_user(email, password, opt={})
      user = User.new email: email, password: password
      user.api_key = opt[:api_key] if opt[:api_key]
      user.admin = true if opt[:admin]
      user.save
      return user
    end

  end
end
