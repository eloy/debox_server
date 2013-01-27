require 'debox_server/throw_async'

module DeboxServer
  module API
    module V1

      class Live < Grape::API

        version 'v1'

        before do
          authenticate!
        end

        helpers do
          include ThrowEventSource

          def job_live_log(id)
            async do
              log.info "Live connection to job ##{id}"
              job = jobs_queue.find id.to_i
              if job
                keep_alive # Keep alive the connection sending empty packages
                chunk job.buffer unless job.buffer.empty? # Show current buffer

                sid = job.subscribe{ |l| chunk l }

                job.on_finish do
                  job.unsubscribe sid
                  close
                end

              else
                chunk "Job not running."
                close
              end

              before_close do
                log.debug "Live connection to job ##{id} clossed"
                job.unsubscribe sid if job
              end

            end
          end
        end

        resource :live do
          get '/log/job/:id' do
            job_live_log params[:id]
          end

          # get '/log/:app/:env' do
          #   live_log current_app, current_env
          # end

          # get '/log/:app' do
          #   live_log current_app, current_env
          # end

        end
      end
    end
  end
end
