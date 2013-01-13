require 'spec_helper'

describe DeboxServer::ACL do
  describe 'acl_find' do
    it 'should find the app acl for the given user' do
      email = 'test@indeos.es'
      DeboxServer::RedisDB::redis.hset server.acl_key_name('app', 'env'), email, ['*', 'cap'].to_json
      server.acl_find('app', 'env', email).should eq ['*', 'cap']
    end

    it 'should return nil if not found' do
      email = 'test@indeos.es'
      server.acl_find('app', 'env', email).should be_nil
    end

  end
end
