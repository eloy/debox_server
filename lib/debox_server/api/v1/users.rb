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
            error!("Can't create user", 400) unless user
            "ok"
          end

          # TODO validate params
          delete '/destroy' do
            error!("Invalid param", 400) unless params[:user]
            users_destroy params[:user]
            "ok"
          end

        end
      end
    end
  end
end
