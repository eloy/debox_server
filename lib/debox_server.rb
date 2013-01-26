require 'json'
require 'fileutils'
require 'erb'

require 'grape'
# require 'rack/stream'

require "debox_server/version"
require "debox_server/logger"
require "debox_server/config"
require "debox_server/utils"
require 'debox_server/redis'
require "debox_server/ssh_keys"
require "debox_server/apps"
require "debox_server/users"
require "debox_server/recipes"
require "debox_server/deploy_logs"
require "debox_server/job"
require "debox_server/job_notifier"
require "debox_server/job_queue"
require "debox_server/acl"


# TODO get root without the ../
DEBOX_ROOT = File.join(File.dirname(__FILE__), '../')

module DeboxServer
  include DeboxServer::Utils
  include DeboxServer::Config
  include DeboxServer::RedisDB
  include DeboxServer::SshKeys
  include DeboxServer::Apps
  include DeboxServer::Users
  include DeboxServer::Recipes
  include DeboxServer::DeployLogs
  include DeboxServer::ACL
end


class DeboxServerCore
  include DeboxServer
end
