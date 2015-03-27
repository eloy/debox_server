module DeboxServer

  module AESCrypt
    CIPHER_TYPE = "AES-256-ECB"
    KEY = "12345678"

    def decrypt(encrypted_data)
      aes = OpenSSL::Cipher::Cipher.new(CIPHER_TYPE)
      aes.decrypt
      aes.key = key
      aes.update(encrypted_data) + aes.final
    end

    def encrypt(data)
      aes = OpenSSL::Cipher::Cipher.new(CIPHER_TYPE)
      aes.encrypt
      aes.key = key
      aes.update(data) + aes.final
    end

    def key
      @key ||= build_key
    end

    private

    def build_key
      digest = Digest::SHA256.new
      digest.update("symetric key")
      digest.digest
    end
  end


  module BasicAuth
    include AESCrypt

    def authenticate!
      unless logged_in?
        log.info "Access denied"
        error!("Access Denied", 401)
      end
    end


    def current_user
      @current_user ||= authenticate_user
    end

    def logged_in?
      current_user != false
    end

    # Authorization
    #----------------------------------------------------------------------

    def require_admin
      error!("Forbidden", 403) unless current_user.admin
    end

    def require_auth_for(action, opt = { })
      app = opt[:app] || current_app
      recipe = opt[:env] || current_env
      user = opt[:user] || current_user
      unless user.can? action, on: recipe
        log.info "Forbidden"
        error!("Forbidden", 403)
      end
    end


    private

    def write_cookie(user)
      content = { email: user.email, api_key: user.api_key }.to_json
      cookies[:debox_auth] = {
        value: encrypt(content),
        expires: 1.year.from_now,
        path: '/'
      }
    end


    def read_cookie
      return false unless cookies[:debox_auth]

      begin
        content = decrypt(cookies[:debox_auth])
        auth = JSON.parse content
        login_api_key auth['email'], auth['api_key']
      rescue
        cookies.delete :debox_auth, path: '/'
        return false
      end
    end


    def authenticate_with_basic_auth
      auth = Rack::Auth::Basic::Request.new(request.env)
      return false unless auth.provided? && auth.basic? && auth.credentials
      login_api_key auth.credentials.first, auth.credentials.last
    end

    def authenticate_user
      # First, try to read the cookie
      user = read_cookie
      return user if user

      # Try basic auth
      user = authenticate_with_basic_auth

      # Write the session cookie
      write_cookie(user) if user
      return user
    end


  end
end
