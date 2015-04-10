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
            User.order("id asc").map do |user|
              user.to_jbuilder.attributes!
            end
          end

          get "/:id" do
            user = User.find params[:id]
            user.to_jbuilder(verbose: true).attributes!
          end

          post '/create' do
            user = add_user params[:user], params[:password]
            error!("Can't create user", 400) unless user
            user.to_jbuilder.attributes!
          end

          # Update
          put '/:id' do
            user = User.find params[:id]
            unless user.update_attributes extract_params :user, [:password, :admin]
              error!("Can't update user", 400)
            end
            user.to_jbuilder(verbose: true).attributes!
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
