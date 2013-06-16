require 'rubygems'
require 'bundler'

ENV['DEBOX_ROOT'] ||= File.dirname __FILE__

Bundler.require
require "debox_server/api"

run DeboxServer::DeboxAPI