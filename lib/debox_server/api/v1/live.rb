require 'debox_server/throw_async'

module DeboxServer
  module API
    module V1

      class Live < Grape::API

        version 'v1'

        before do
          authenticate!
          require_auth_for :logs
        end

        helpers do
          include ThrowEventSource

          def live_log(app, env)
            async do
              DeboxServer.log.info "New live connection to #{app} #{env}"
              @job = DeboxServer::Deployer::running_job app, env
              if @job && (params[:job_id].nil? || params[:job_id] == @job.id)
                keep_alive # Keep alive the connection sending empty packages
                chunk @job.buffer unless @job.buffer.empty? # Show current buffer
                @sid = @job.subscribe{ |l| chunk l }
                @job.on_finish do
                  @job.unsubscribe @sid
                  close
                end
              else
                chunk "Job not running."
                close
              end

              before_close do
                DeboxServer.log.debug "Closed connection to #{app} #{env}"
                @job.unsubscribe @sid if @job
              end

            end
          end
        end

        resource :live do
          get '/log/:app/:env' do
            live_log current_app, current_env
          end

          get '/log/:app' do
            live_log current_app, current_env
          end

        end
      end
    end
  end
end
