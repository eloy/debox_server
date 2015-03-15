require 'rubygems'
require 'bundler'
require 'sprockets'

ENV['DEBOX_ROOT'] ||= File.dirname __FILE__

Bundler.require
require "debox_server/api"
require "debox_server/assets_server"

# run DeboxServer::DeboxAPI

run DeboxServer::AssetsServer.new(root: File.join(ENV['DEBOX_ROOT'], 'ui', 'public'),  urls: %w[/])
