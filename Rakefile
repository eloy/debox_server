#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'debox_server'

namespace :auth do

  desc 'create a user'
  task :create do
    STDOUT.puts "Email:  "
    email = STDIN.gets.strip

    STDOUT.puts "\nAdmin password:"
    password = STDIN.gets.strip
    dbox = DeboxServer::Core.new
    if dbox.add_user email, password
      STDOUT.puts "\nUser created"
    else
      STDOUT.puts "\nCan't create user."
    end
  end

  desc 'list users'
  task :list  do
    dbox = DeboxServer::Core.new
    dbox.users_config.keys.each do |user|
      STDOUT.puts user
    end
  end

  desc 'Generate rsa key'
  task :ssh_keygen do
    system 'ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ""'
  end

end
