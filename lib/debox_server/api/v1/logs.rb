module DeboxServer
  module API
    module V1

      class Logs < Grape::API

        version 'v1'
        format :json

        before do
          authenticate!
          require_auth_for :logs
        end

        helpers do

          def get_logs_helper(app, env)
            logs = deployer_logs app, env
            out = logs.map do |l|
              { status: l[:status], task: l[:task], time: l[:time], error: l[:error] }
            end
            out
          end

          def show_log(app, env, index=0)
            log = deployer_logs_at current_app, current_env, index
            error!("Log not found", 400) unless log
            log[:log]
          end

        end

        resource :logs do

          get "/:app" do
            get_logs_helper current_app, current_env
          end

          get "/:app/:env" do
            get_logs_helper current_app, current_env
          end
        end


        resource :log do
          get "/:app/:env" do
            show_log current_app, current_env, params[:index]
          end

          get "/:app" do
            show_log current_app, current_env, params[:index]
          end
        end

      end
    end
  end
end
