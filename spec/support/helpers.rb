class FakeServer
  include DeboxServer::App
end

def server
  @server ||= DeboxServer::Core.new
end

def create_user(opt={ })
  email = opt[:email] || 'test@indeos.es'
  password = opt[:password] || 'secret'
  return FakeServer.new.add_user email, password, opt
end

def login_user(user=create_user)
  authorize user.email, user.api_key
end

def find_user(email)
  FakeServer.new.find_user email
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
