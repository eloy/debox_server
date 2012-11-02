class FakeServer
  include DeboxServer::App
end

def create_user(email='test@indeos.es')
  user = FakeServer.new.add_user email, 'secret'
  user[:email] = email
  return user
end

def login_user(user=create_user)
  authorize user[:email], user[:api_key]
end

def config_dir
  ENV['DEBOX_SERVER_CONFIG']
end

def recipes_dir
  File.join config_dir, DeboxServer::Recipes::RECIPES_DIR
end

def recipes_dir!
  Dir.mkdir(recipes_dir) unless Dir.exists? recipes_dir
  recipes_dir
end

def recipes_app_dir(app)
  File.join recipes_dir, app
end

def recipes_app_dir!(app)
  app_dir = File.join recipes_dir!, app
  Dir.mkdir(app_dir) unless Dir.exists? app_dir
  app_dir
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
