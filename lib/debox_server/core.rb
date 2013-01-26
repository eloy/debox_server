module DeboxServer

  module App
    include DeboxServer::Utils
    include DeboxServer::Config
    include DeboxServer::RedisDB
    include DeboxServer::SshKeys
    include DeboxServer::Apps
    include DeboxServer::Users
    include DeboxServer::Recipes
    include DeboxServer::DeployLogs
    include DeboxServer::JobQueue
    include DeboxServer::ACL
  end

  class Core
    include DeboxServer::App
  end

end
