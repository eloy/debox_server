module DeboxServer
  module API
    module V1

      class ACL < Grape::API

        version 'v1'
        format :json

        before do
          authenticate!
        end


        helpers do
          def allowed?
            action = params[:action].to_sym
            user = current_user
            # Admins can override users
            if params[:user] && current_user.admin
              user = find_user params[:user]
            end
            if acl_allow? current_app, current_env, user, action
              return "YES"
            else
              error!("User is not allowed to run this action", 403)
            end
          end
        end

        resource :acl do

          desc "Check if the user is authorized for a given action and env"
          params do
            requires :action, type: String, desc: "action for check authorization"
            optional :user, type: String, desc: "optional user for check authorization. Require admin access."
          end
          get '/allowed/:app/:env' do
            allowed?
          end

          desc "Check if the user is authorized for a given action and default env"
          params do
            requires :action, type: String, desc: "action for check authorization"
            optional :user, type: String, desc: "optional user for check authorization. Require admin access."
          end
          get '/allowed/:app' do
            allowed?
          end

        end

      end
    end
  end
end
