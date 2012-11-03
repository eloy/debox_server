require 'digest/md5'
module DeboxServer

  def self.environment
    ENV['RACK_ENV'] ? ENV['RACK_ENV'].to_sym : :development
  end

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
