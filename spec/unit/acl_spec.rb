require 'spec_helper'

describe DeboxServer::ACL do
  describe 'acl_find' do
    it 'should find the app acl for the given user' do
      email = 'test@indeos.es'
      DeboxServer::RedisDB::redis.hset server.acl_key_name('app', 'env'), email, [:*, :cap].to_json
      server.acl_find('app', 'env', email).should eq [:*, :cap]
    end

    it 'should return nil if not found' do
      email = 'test@indeos.es'
      server.acl_find('app', 'env', email).should be_nil
    end
  end

  describe 'acl_add' do
    it 'should create an acl with the given action' do
      server.acl_add 'app', 'env', 'test@indeos.es', :cap
      server.acl_find('app', 'env', 'test@indeos.es').should eq [:cap]
    end
    it 'should add actions to the current acl' do
      server.acl_add 'app', 'env', 'test@indeos.es', :cap
      server.acl_add 'app', 'env', 'test@indeos.es', :recipes
      server.acl_find('app', 'env', 'test@indeos.es').should eq [:cap, :recipes]
    end

  end

end
