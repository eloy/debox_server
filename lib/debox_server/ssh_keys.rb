# Store keys in redis for servers without storage
module DeboxServer
  module SshKeys
    include DeboxServer::Utils

    SSH_DIR = File.join ENV['HOME'], '.ssh'
    PUBLIC_KEY = File.join SSH_DIR, 'id_rsa.pub'
    PRIVATE_KEY = File.join SSH_DIR, 'id_rsa'

    def ssh_public_key
      REDIS.hget 'ssh_keys', :public_key
    end

    # Rake helpers
    #----------------------------------------------------------------------

    def ssh_keys_import
      return false unless File.exists? PUBLIC_KEY
      return false unless File.exists? PRIVATE_KEY
      public = File.open(PUBLIC_KEY).read
      private = File.open(PRIVATE_KEY).read
      REDIS.hset 'ssh_keys', :public_key, public
      REDIS.hset 'ssh_keys', :private_key,  private
    end

    def ssh_keys_export
      public = REDIS.hget 'ssh_keys', :public_key
      private = REDIS.hget 'ssh_keys', :private_key
      return false if public.empty? || private.empty?
      save_file PRIVATE_KEY, private
      save_file PUBLIC_KEY, public
      FileUtils.chmod 0600, PRIVATE_KEY
      FileUtils.chmod 0600, PUBLIC_KEY
    end

  end
end
