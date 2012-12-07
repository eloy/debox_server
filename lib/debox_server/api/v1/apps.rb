module DeboxServer
  module API
    module V1

      class Apps < Grape::API

        version 'v1'
        format :json

        before do
          authenticate!
        end

        desc "Return configured apps"
        get '/apps' do
          apps_list
        end

      end
    end
  end
end
