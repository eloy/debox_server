require "debox_server/basic_auth"
require "debox_server/view_helpers"

# Require controllers
Dir[File.join(File.dirname(__FILE__), "api/v1/", "*.rb")].each do |file|
  require file
end

module DeboxServer

  class DeboxAPI < Grape::API

    helpers DeboxServer
    helpers DeboxServer::BasicAuth
    helpers DeboxServer::ViewHelpers

    # Exceptions management
    #----------------------------------------------------------------------

    rescue_from ActiveRecord::RecordNotFound do |e|
      Rack::Response.new e.message, 400
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      Rack::Response.new e.message, 400
    end

    rescue_from :all

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
