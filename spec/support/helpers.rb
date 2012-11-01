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


def find_user(email)
  FakeServer.new.find_user email
end


def hash_str(str)
  Digest::MD5.hexdigest str
end

def md5_file(filename)
  Digest::MD5.file(filename)
end
