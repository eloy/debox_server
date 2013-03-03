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
            App.all.each do |app|
              recipes = recipes_list app.name
              apps << { app: app.name, envs: recipes }
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
