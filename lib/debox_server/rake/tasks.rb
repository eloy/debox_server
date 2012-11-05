require 'rake'

namespace 'auth' do

  # User management
  #----------------------------------------------------------------------

  desc 'create a user'
  task :user_create do
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
  task :user_list  do
    dbox = DeboxServer::Core.new
    dbox.users_config.keys.each do |user|
      STDOUT.puts user
    end
  end

  # ssh keys management
  #----------------------------------------------------------------------

  desc 'Generate rsa key'
  task :ssh_keygen do
    Dir.mkdir('~/.ssh') unless Dir.exists? '~/.ssh'
    system 'ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ""'
  end

  desc 'Import ssh key'
  task :ssh_keys_import do
    dbox = DeboxServer::Core.new
    dbox.ssh_keys_import
    STDOUT.puts "\nKeys imported."
  end

  desc 'Export ssh key. WARNING, it will overwrite system keys'
  task :ssh_keys_export do
    dbox = DeboxServer::Core.new
    dbox.ssh_keys_export
    STDOUT.puts "\nKeys exported."
  end
end
