require 'json'
require 'fileutils'
require 'erb'

require 'grape'

# TODO get root without the ../
DEBOX_ROOT = File.join(File.dirname(__FILE__), '../')

require "debox_server/version"
require "debox_server/logger"
require "debox_server/config"
require "debox_server/utils"
require 'debox_server/redis'
require 'debox_server/activerecord'
require "debox_server/ssh_keys"
require "debox_server/apps"
require "debox_server/users"
require "debox_server/recipes"

require "debox_server/job_notifier"
require "debox_server/jobs_queue"

module DeboxServer
  include DeboxServer::Logger
  include DeboxServer::RedisDB
  include DeboxServer::Utils
  include DeboxServer::Config
  include DeboxServer::SshKeys
  include DeboxServer::Apps
  include DeboxServer::Users
  include DeboxServer::Recipes
end


class DeboxServerCore
  include DeboxServer
end
