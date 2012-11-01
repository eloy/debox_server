class FakeServer
  include DeboxServer::App
end


def create_user(email)
  FakeServer.new.add_user email, 'secret'
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
