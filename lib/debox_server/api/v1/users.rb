module DeboxServer
  module API
    module V1

      class Users < Grape::API

        version 'v1'
        format :json

        before do
          authenticate!
        end

        resource :users do
          get do
            users_config.keys
          end

          post '/create' do
            user = add_user params[:user], params[:password]
            throw(:halt, [400, "Unvalid request\n"]) unless user
            "ok"
          end

          delete '/destroy' do
            throw(:halt, [400, "Unvalid request\n"]) unless params[:user]
            users_destroy params[:user]
            "ok"
          end

        end
      end
    end
  end
end
