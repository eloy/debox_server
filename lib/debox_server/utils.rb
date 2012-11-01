require 'digest/md5'
module DeboxServer

  module Utils
    def hash_str(str)
      Digest::MD5.hexdigest str
    end

    def md5_file(filename)
      Digest::MD5.file(filename)
    end

    def generate_uuid
      SecureRandom.uuid
    end
  end
end
