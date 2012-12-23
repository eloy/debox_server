module DeboxServer
  module API
    module V1

      class Apps < Grape::API

        version 'v1'
        format :json

        before do
          authenticate!
        end


        helpers do
          def detailed_apps_list
            apps = []
            apps_list.each do |app|
              recipes = recipes_list app
              apps << { app: app, envs: recipes }
            end
            return apps
          end
        end


        desc "Return configured apps"
        get '/apps' do
          detailed_apps_list
        end

      end
    end
  end
end
