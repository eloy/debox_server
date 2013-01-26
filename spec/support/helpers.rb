require 'base64'
class FakeServer
  include DeboxServer::App
end

def server
  @server ||= DeboxServer::Core.new
end

def create_user(opt={ })
  @user_id_counter ||= 0
  id = @user_id_counter += 1
  email = opt[:email] || "user_#{id}@indeos.es"
  password = opt[:password] || 'secret'
  server.add_user email, password, opt
end

def create_admin(opt={ })
  opt[:admin] = true # Ensure user will be an admin
  create_user opt
end

def login_as_user(user=create_user)
  authorize user.email, user.api_key
end

def login_as_admin(user=create_admin)
  authorize user.email, user.api_key
end

# Basic auth for webkit
def login_as_user!(user=create_user)
  auth = [user.email, user.api_key].join(':')
  auth_string = Base64.strict_encode64 auth
  driver = Capybara.current_session.driver
  driver.header "Authorization", "Basic #{auth_string}"
end

def login_as_admin!(admin=create_admin)
  login_as_user! admin
end

def find_user(email)
  server.find_user email
end

def hash_str(str)
  Digest::MD5.hexdigest str
end

def md5_file(filename)
  Digest::MD5.file(filename)
end


# Build a job with stdout and capistrano methos stubbed
def stubbed_job(app, env, task='deploy', out=nil)
  out = OpenStruct.new time: DateTime.now, success: true unless out
  job = DeboxServer::Job.new(app, env, task)
  job.stub(:stdout) { out }
  job.stub(:capistrano) { { } }
  return job
end
