# Store keys in redis for servers without storage
module DeboxServer
  module SshKeys
    include DeboxServer::Utils

    SSH_DIR = File.join ENV['HOME'], '.ssh'
    PUBLIC_KEY = File.join SSH_DIR, 'id_rsa.pub'
    PRIVATE_KEY = File.join SSH_DIR, 'id_rsa'

    def ssh_public_key
      @@public_key ||= read_ssh_public_key
    end

    # Rake helpers
    #----------------------------------------------------------------------

    # Ensure public and private keys availables in the system
    def self.init_ssh_subsystem
      return true if ssh_keys_presents?
      public = REDIS.hget 'ssh_keys', :public_key
      private = REDIS.hget 'ssh_keys', :private_key
      if public.empty? || private.empty?
        # Generate keys if not present
        ssh_keygen
        ssh_keys_import
      else
        # Else, export current keys
        ssh_keys_export
      end
      puts "SSH subsystem ready"
    end

    def self.ssh_keygen
      return true if ssh_keys_presents?
      prepare_ssh_dir
      system 'ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ""'
    end

    def self.ssh_keys_presents?
      File.exists?(PUBLIC_KEY) || File.exists?(PRIVATE_KEY)
    end

    def self.prepare_ssh_dir
      Dir.mkdir(SSH_DIR) unless Dir.exists? SSH_DIR
    end

    def self.ssh_keys_import
      raise "Can't find ssh keys" unless ssh_keys_presents?
      RedisDB::check_redis_connection!
      public = File.open(PUBLIC_KEY).read
      private = File.open(PRIVATE_KEY).read
      REDIS.hset 'ssh_keys', :public_key, public
      REDIS.hset 'ssh_keys', :private_key,  private
    end

    def self.ssh_keys_export
      raise 'SSH keys already present' if ssh_keys_presents?
      RedisDB::check_redis_connection!
      public = REDIS.hget 'ssh_keys', :public_key
      private = REDIS.hget 'ssh_keys', :private_key
      if public.nil? || public.empty? || private.nil? || private.empty?
        raise 'SSH keys not found'
      end
      prepare_ssh_dir
      DeboxServer::Utils.save_file PRIVATE_KEY, private
      DeboxServer::Utils.save_file PUBLIC_KEY, public
      FileUtils.chmod 0600, PRIVATE_KEY
      FileUtils.chmod 0600, PUBLIC_KEY
    end

    private
    def read_ssh_public_key
      raise 'RSA public key not present.' unless SshKeys::ssh_keys_presents?
      File.open(PUBLIC_KEY).read
    end
  end
end
