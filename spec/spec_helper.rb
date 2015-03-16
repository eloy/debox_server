# TODO: better way for deal with envs
ENV['RACK_ENV'] = 'test'
ENV['DEBOX_ROOT'] = File.join(File.dirname(__FILE__), '../')

require 'rubygems'
require 'bundler'
Bundler.require

require 'rspec'
require 'rack/test'
require 'factory_girl'
require 'database_cleaner'
require 'minitest'
require 'shoulda-matchers'
require "debox_server/api"
require 'debox_server/test_helper'
require 'factories'

# Prepare capybara
require 'capybara/rspec'
require 'capybara/webkit'

Capybara.app = DeboxServer::DeboxAPI

def app
  DeboxServer::DeboxAPI
end

# Set debug level to error
# TODO: Set by conf anywhere
DeboxServer::log.level = Log4r::ERROR

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|

  config.include Rack::Test::Methods

  # Setup capybara
  Capybara.javascript_driver = :webkit
  # Capybara.server_boot_timeout = 50
  Capybara.server_port = 8082
  Capybara.default_wait_time = 5

  # Factories and Database
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    if example.metadata[:js]
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.start
    end
  end

  config.after(:each) do
    DatabaseCleaner.clean       # Truncate the database
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver

    if example.metadata[:js]
      DatabaseCleaner.strategy = :transaction
    end
  end

end
