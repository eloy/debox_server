require 'rake'

# User management
#----------------------------------------------------------------------

namespace 'users' do

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

  desc 'Add admin privileges to a user'
  task :make_admin do
    STDOUT.puts "Email:  "
    email = STDIN.gets.strip

    dbox = DeboxServer::Core.new
    dbox.users_make_admin! email
    STDOUT.puts "\nUser #{email} is now an admin"
  end

  desc 'Remove admin privileges for a user'
  task :remove_admin do
    STDOUT.puts "Email:  "
    email = STDIN.gets.strip

    dbox = DeboxServer::Core.new
    dbox.users_remove_admin! email
    STDOUT.puts "\nUser is not an admin anymore"
  end


end

# ssh keys management
#----------------------------------------------------------------------

namespace 'ssh' do

  desc 'Initialize ssh subsystem'
  task :init_subsystem do
    DeboxServer::SshKeys.init_ssh_subsystem
  end

  desc 'Generate rsa key'
  task :keygen do
    DeboxServer::SshKeys.ssh_keygen
  end

  desc 'Import ssh key'
  task :keys_import do
    DeboxServer::SshKeys.ssh_keys_import
    STDOUT.puts "\nKeys imported."
  end

  desc 'Export ssh key. WARNING, it will overwrite system keys'
  task :keys_export do
    DeboxServer::SshKeys.ssh_keys_export
    STDOUT.puts "\nKeys exported."
  end
end
