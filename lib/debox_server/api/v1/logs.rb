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

          def get_logs_helper(recipe)
            recipe.jobs.map do |job|
              { success: job.success, task: job.task, start_time: job.start_time, end_time: job.end_time, error: job.error }
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
            get_logs_helper current_env
          end

          get "/:app/:env" do
            get_logs_helper current_env
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
