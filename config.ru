require 'rubygems'
require 'bundler'

Bundler.require

use Rack::Reloader
run DeboxServer::DeboxAPI