module DeboxServer
  module API
    module V1

      class Users < Grape::API

        version 'v1'
        format :json

        before do
          authenticate!
          require_admin
        end

        resource :users do
          get do
            User.all.map(&:email)
          end

          post '/create' do
            user = add_user params[:user], params[:password]
            error!("Can't create user", 400) unless user
            "ok"
          end

          # TODO validate params
          delete '/destroy' do
            error!("Invalid param", 400) unless params[:user]
            user = User.find_by_email params[:user]
            error!("Invalid user", 400) unless user
            user.destroy
            "ok"
          end

        end
      end
    end
  end
end
