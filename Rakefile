#!/usr/bin/env rake
require "bundler/gem_tasks"


# Import rake tasks for debox_server
# if available or show alert otherwise
begin
  require 'debox_server'
  require 'debox_server/rake/tasks'
rescue Exception
  puts "debox_server gem is not installed globaly. Specifics tasks will not be availables."
end
