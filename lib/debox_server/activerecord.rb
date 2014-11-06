require 'active_record'

module DeboxServer
  ActiveRecord::Base.configurations = Config::db_conf
  current_env = (ENV['RACK_ENV'] || 'development')
  # drop and create need to be performed with a connection to the 'postgres' (system) database
  ActiveRecord::Base.establish_connection Config::db_conf[current_env]


  # Setup defaults
  ActiveRecord::Base.include_root_in_json = false
end

# Require models
Dir[File.join(File.dirname(__FILE__), "model", "*.rb")].each do |file|
  require file
end
