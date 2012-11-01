require 'rubygems'
require 'bundler'

Bundler.require
require 'debox_server'
require 'sinatra'
require 'rack/test'

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

  config.before(:suite) do
    FileUtils.mkdir_p( File.join(DEBOX_ROOT, 'tmp', 'specs'))
  end

  # Before each run create an empty config dir
  config.before(:each) do
    @tmp_dir = Dir.mktmpdir File.join(DEBOX_ROOT, 'tmp', 'specs', 'config')
    ENV['DEBOX_SERVER_CONFIG'] = @tmp_dir
  end

  config.after(:each) do
    FileUtils.rm_rf @tmp_dir
  end

  config.include Rack::Test::Methods
end
