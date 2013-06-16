require 'base64'
class FakeServer
  include DeboxServer
end

def server
  @server ||= DeboxServerCore.new
end

def create_user(opt={ })
  create :user, opt
end

def create_admin(opt={ })
  create :admin, opt
end

def login_as_user(user=create(:user))
  authorize user.email, user.api_key
end

def login_as_admin(user=create(:admin))
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

def hash_str(str)
  Digest::MD5.hexdigest str
end

def md5_file(filename)
  Digest::MD5.file(filename)
end


# Build a job with stdout and capistrano methos stubbed
def stubbed_job(app_name, env_name, task='deploy', out=nil)
  app = App.find_by_name_or_create app_name
  recipe = app.recipes.find_by_name(env_name) || create(:recipe, app: app)
  out = OpenStruct.new time: DateTime.now, success: true unless out
  job = Job.new(recipe: recipe, task: task)
  job.stub(:stdout) { out }
  job.stub(:capistrano) { { } }
  job.send(:update_job_status)
  return job
end
