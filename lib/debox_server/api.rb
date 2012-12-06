module DeboxServer
  class DeboxAPI < Grape::API

    helpers DeboxServer::App
    helpers DeboxServer::BasicAuth
    helpers DeboxServer::ViewHelpers

    # V1
    #----------------------------------------------------------------------
    mount DeboxServer::API::V1::Users
    mount DeboxServer::API::V1::Logs
  end
end
