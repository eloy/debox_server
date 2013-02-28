module DeboxServer
  module API
    module V1

      class Cap < Grape::API

        version 'v1'
        format :json

        before do
          authenticate!
          require_auth_for :cap
        end

        helpers do
          def run_cap_task(app, env, task='deploy')
            job = Job.new(app, env, task)
            jobs_queue.add(job)
            { job_id: job.id , app: app, env: env, task: task }
          end
        end

        desc "Run a capistrano task for a on a given app if only one env configured"
        get "/cap/:app" do
          run_cap_task(current_app, current_env, params[:task] || 'deploy')
        end

        desc "Run a capistrano task for a on a given app and env"
        get "/cap/:app/:env" do
          run_cap_task(current_app, current_env, params[:task] || 'deploy')
        end

      end
    end
  end
end
