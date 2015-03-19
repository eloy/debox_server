module DeboxServer
  module API
    module V1

      class Logs < Grape::API

        version 'v1'

        before do
          authenticate!
          require_auth_for :logs
        end

        helpers do

          def get_logs_helper(recipe)
            recipe.jobs.order('id desc').map do |job|
              job.to_jbuilder(no_log: true).attributes!
            end
          end

          def show_log(recipe, job_id = false)
            if job_id
              job = recipe.jobs.find job_id
            else
              job = recipe.jobs.last
            end
            error!("job not found", 400) unless job
            job.log
          end

        end

        resource :logs do

          get "/:app" do
            get_logs_helper(current_env).to_json
          end

          get "/:app/:env" do
            get_logs_helper(current_env).to_json
          end
        end


        resource :log do
          get "/:app/:env" do
            show_log current_env, params[:job_id]
          end

          get "/:app" do
            show_log current_env, params[:job_id]
          end
        end

      end
    end
  end
end
