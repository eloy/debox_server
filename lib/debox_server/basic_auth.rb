module DeboxServer
  module BasicAuth
    include DeboxServer::Users

    def authenticate!
      error!("Access Denied", 401) unless authorized?
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      return false unless @auth.provided? && @auth.basic? && @auth.credentials
      return login_api_key @auth.credentials.first, @auth.credentials.last
    end
  end
end
