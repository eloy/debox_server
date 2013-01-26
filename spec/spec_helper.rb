# TODO: better way for deal with envs
ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler'

Bundler.require
require 'rack/test'
require 'debox_server/test_helper'

# Prepare capybara
require 'capybara/rspec'
require 'capybara/webkit'
Capybara.app = DeboxServer::DeboxAPI

def app
  DeboxServer::DeboxAPI
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|

  config.after(:each) do
    DeboxServer::RedisDB.flush_test_db
  end

  config.include Rack::Test::Methods

  # Setup capybara
  Capybara.javascript_driver = :webkit
  Capybara.server_boot_timeout = 50
  Capybara.server_port = 8082
  Capybara.default_wait_time = 5

end
