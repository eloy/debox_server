module DeboxServer
  module API
    module V1

      class Sessions < Grape::API

        version 'v1'
        format :json

        desc "Login and return the api_key for the user"
        post "/session" do
          user = login_user(params[:user], params[:password])
          error!("Not authorized", 401) unless user
          write_cookie(user) # TODO: Move session to other endpoint
          user.to_jbuilder.attributes!
        end

        desc "Session information"
        get "/session" do
          authenticate!
          current_user.to_jbuilder.attributes!
        end

      end
    end
  end
end
