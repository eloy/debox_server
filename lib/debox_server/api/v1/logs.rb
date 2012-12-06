module DeboxServer
  module API
    module V1

      class Logs < Grape::API

        version 'v1'
        format :json

        # before do
        #   authenticate!
        # end

        resource :logs do
          # get "/live_log/:app/?:env?/?:job_id?" do
          #   stream(:keep_open) do |out|

          #     job = DeboxServer::Deployer::running_job current_app, current_env
          #     if job && (params[:job_id].nil? || params[:job_id] == job.id)
          #       out.puts "Living log for #{job.id}:"
          #       out.puts job.buffer # Show current buffer
          #       sid = job.subscribe out
          #       out.callback { job.unsubscribe(out, sid) }
          #       out.errback { job.unsubscribe(out, sid) }
          #     else
          #       out.puts "Not running"
          #       out.flush
          #       out.close
          #     end
          #   end
          # end

          params do
            requires :app, type: String
            optional :env, type: String
          end
          get "/:app/:env" do
            logs = deployer_logs current_app, current_env
            out = logs.map do |l|
              { status: l[:status], task: l[:task], time: l[:time], error: l[:error] }
            end
            out
          end

          get "/:app/:env/:index" do
            index = params[:index] == 'last' ? 0 : params[:index]
            log = deployer_logs_at current_app, current_env, index
            error!("Log not found", 400) unless log
            log[:log]
          end


        end

      end
    end
  end
end
