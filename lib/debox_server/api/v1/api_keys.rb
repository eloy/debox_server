module DeboxServer
  module API
    module V1

      class ApiKeys < Grape::API

        version 'v1'
        format :txt

        desc "Login and return the api_key for the user"
        get "/api_key" do
          user = login_user(params[:user], params[:password])
          error!("Not authorized", 401) unless user
          user.api_key
        end

      end
    end
  end
end
