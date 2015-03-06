module DeboxServer
  module API
    module V1

      class Sessions < Grape::API

        version 'v1'
        format :txt

        desc "Login and return the api_key for the user"
        get "/session/new" do
          user = login_user(params[:user], params[:password])
          error!("Not authorized", 401) unless user
          write_cookie(user) # TODO: Move session to other endpoint
          "OK"
        end

      end
    end
  end
end
