module DeboxServer
  module API
    module V1

      class Site < Grape::API

        version 'v1'
        format :json

        get '/' do
          'debox'
        end

      end
    end
  end
end
