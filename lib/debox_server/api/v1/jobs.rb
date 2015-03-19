module DeboxServer
  module API
    module V1

      class Logs < Grape::API

        version 'v1'

        before do
          authenticate!
          require_auth_for :logs
        end

        desc "Stop the job"
        params do
          requires :id, type: Integer, desc: "job id"
        end
        post "/apps/:app/envs/:env/jobs/:id/stop" do
          job = jobs_queue.find params[:id]
          error!("job not found", 400) unless job
          job.kill!
        end


      end

    end
  end
end
