module DeboxServer
  module BasicAuth
    include DeboxServer::Users

    def authenticate!
      error!("Access Denied", 401) unless logged_in?
    end

    def authenticate
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      return false unless @auth.provided? && @auth.basic? && @auth.credentials
      @current_user = login_api_key @auth.credentials.first, @auth.credentials.last
    end

    def current_user
      @current_user ||= authenticate
    end

    def logged_in?
      current_user != false
    end

    # Authorization
    #----------------------------------------------------------------------

    def require_admin
      error!("Forbidden", 403) unless current_user.admin
    end

  end
end
