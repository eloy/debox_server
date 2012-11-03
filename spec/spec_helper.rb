# TODO: better way for deal with envs
ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler'

Bundler.require
require 'sinatra'
require 'rack/test'

# require 'debox_server/spec_helper'

# setup test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

def app
  DeboxServer::HTTP
end

# Require support files
Dir[File.join(DEBOX_ROOT, "spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.after(:each) do
    REDIS.select DeboxServer::RedisDB.redis_db_no
    REDIS.flushdb
  end

  config.include Rack::Test::Methods
end
