require 'rake'

# User management
#----------------------------------------------------------------------


RACK_ENV = ENV['RACK_ENV'] || 'development'
DEBOX_ROOT = File.join(File.dirname(__FILE__), '../../../')

def debox
  @debox_server ||= DeboxServerCore.new
end

namespace 'users' do

  desc 'create a user'
  task :create do
    STDOUT.puts "Email:  "
    email = STDIN.gets.strip

    STDOUT.puts "\nAdmin password:"
    password = STDIN.gets.strip
    user = User.new email: email, password: password
    user.admin = true
    if user.save
      STDOUT.puts "\nUser created"
    else
      STDOUT.puts "\nCan't create user."
    end
  end

  desc 'list users'
  task :list  do

    STDOUT.puts "email\t\t\t\tapi_key\t\t\t\t\tAdmin"
    User.all.each do |user|
      isAdmin = "YES" if user.admin?
      STDOUT.puts "#{user.email}\t\t\t#{user.api_key}\t#{isAdmin}"
    end
  end

  desc 'Add admin privileges to a user'
  task :make_admin do
    STDOUT.puts "Email:  "
    email = STDIN.gets.strip

    user = User.find_by_email email
    STDOUT.puts "\nUser not found!" and return unless user
    user.make_admin!
    STDOUT.puts "\nUser #{email} is now an admin"
  end

  desc 'Remove admin privileges for a user'
  task :remove_admin do
    STDOUT.puts "Email:  "
    email = STDIN.gets.strip

    user = User.find_by_email email
    STDOUT.puts "\nUser not found!" and return unless user
    user.remove_admin!
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


# Database
#----------------------------------------------------------------------

namespace :db do
  desc "loads database configuration in for other tasks to run"
  task :load_config do
    require 'active_record'
    ActiveRecord::Base.configurations = debox.db_conf
    ActiveRecord::Base.establish_connection debox.db_conf[RACK_ENV]
  end

  desc "creates and migrates your database"
  task :setup => :load_config do
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
  end

  desc "migrate your database"
  task :migrate => :load_config do
    migrations_path = File.join DEBOX_ROOT, 'db', 'migrate'
    ActiveRecord::Migrator.migrate(
      migrations_path,
      ENV["VERSION"] ? ENV["VERSION"].to_i : nil
    )
    Rake::Task["db:schema_dump"].invoke
  end

  task :schema_dump => :load_config do
    require 'active_record/schema_dumper'
    File.open(ENV['SCHEMA'] || "#{DEBOX_ROOT}/db/schema.rb", "w:utf-8") do |file|
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
    end
    Rake::Task["db:schema_dump"].reenable
  end

  desc 'Drops the database'
  task :drop => :load_config do
    ActiveRecord::Base.connection.drop_database debox.db_conf[RACK_ENV]['database']
  end

  desc 'Creates the database'
  task :create do
    ActiveRecord::Base.establish_connection debox.db_conf[RACK_ENV].merge('database'=>nil)
    ActiveRecord::Base.connection.create_database debox.db_conf[RACK_ENV]['database']
  end

  desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
  task :rollback => :load_config do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Migrator.rollback(ActiveRecord::Migrator.migrations_paths, step)
  end

  namespace :test do
    desc "Clone current db to test"
    task :clone do
      ActiveRecord::Base.establish_connection debox.db_conf['test']
      schema = ENV['SCHEMA'] || "#{DEBOX_ROOT}/db/schema.rb"
      load schema
    end
  end
end


# Task for import redis db
namespace :import do
  task :redis do
    file = File.join DEBOX_ROOT, 'db', 'redis_dump.json'
    file_content = File.open(file).read
    redis = JSON.parse file_content

    # Import users
    redis['users'].each do |email, user_data_raw|
      data = JSON.parse user_data_raw, symbolize_names: true
      user = User.new email: data[:email], api_key: data[:api_key], admin: data[:admin]
      # Write real password without re crypt again
      user.send :write_attribute, :password, data[:password]
      user.save
      puts "Import user #{user.email} [#{user.id}]"
    end

    # Import apps
    redis['apps'].each do |app_name|
      app = App.create name: app_name
      puts "Import app #{app.name} [#{app.id}]"
      # import recipes
      redis["#{app_name}_recipes"].each do |env, content|
        recipe = app.recipes.create name: env, content: content
        puts "Import recipe #{recipe.name} [#{recipe.id}]"
        # And import logs
        redis["logger_#{app_name}_#{env}"].each do |log_raw|
          log = JSON.parse log_raw, symbolize_names: true
          start_time = log[:start_time] ? DateTime.parse(log[:start_time]) : DateTime.new
          end_time = log[:end_time] ? DateTime.parse(log[:end_time]) : DateTime.new
          job = recipe.jobs.create task: log[:task], start_time: start_time, end_time: end_time, success: log[:success], log: log[:log], error: log[:error], config: log[:config].to_json
          puts "Import job #{job.start_time} [#{job.id}]"
        end
      end
    end
  end
end
