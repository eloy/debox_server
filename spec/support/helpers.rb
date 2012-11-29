class FakeServer
  include DeboxServer::App
end

def create_user(email='test@indeos.es')
  user = FakeServer.new.add_user email, 'secret'
  return user
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
