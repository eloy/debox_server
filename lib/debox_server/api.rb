# Require controllers
Dir[File.join(File.dirname(__FILE__), "api/v1/", "*.rb")].each do |file|
  require file
end

module DeboxServer

  class DeboxAPI < Grape::API

    helpers DeboxServer::App
    helpers DeboxServer::BasicAuth
    helpers DeboxServer::ViewHelpers

    # V1
    #----------------------------------------------------------------------

    mount DeboxServer::API::V1::Site
    mount DeboxServer::API::V1::Users
    mount DeboxServer::API::V1::Logs
    mount DeboxServer::API::V1::Live
    mount DeboxServer::API::V1::Recipes
    mount DeboxServer::API::V1::Cap
    mount DeboxServer::API::V1::Apps
    mount DeboxServer::API::V1::SshKeys
    mount DeboxServer::API::V1::ApiKeys
    mount DeboxServer::API::V1::ACL
  end

end
