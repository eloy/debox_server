require 'spec_helper'

describe DeboxServer::ACL do

  let(:app) { 'app' }
  let(:env) {  'env' }
  let(:user) {  create_user }

  describe 'acl_find' do
    it 'should find the app acl for the given user' do
      DeboxServer::RedisDB::redis.hset server.acl_key_name(app, env), user.email, [:*, :cap].to_json
      server.acl_find(app, env, user).should eq [:*, :cap]
    end

    it 'should return nil if not found' do
      server.acl_find(app, env, user).should be_nil
    end
  end

  describe 'acl_add' do
    it 'should create an acl with the given action' do
      server.acl_add app, env, user, :cap
      server.acl_find(app, env, user).should eq [:cap]
    end

    it 'should add actions to the current acl' do
      server.acl_add app, env, user, :cap
      server.acl_add app, env, user, :recipes
      server.acl_find(app, env, user).should eq [:cap, :recipes]
    end

    it 'should not include duplicated actions' do
      server.acl_add app, env, user, :cap
      server.acl_add app, env, user, :cap
      server.acl_find(app, env, user).should eq [:cap]
    end
  end

  describe 'acl_remove' do
    it 'should create an acl with the given action' do
      server.acl_add app, env, user, :cap
      server.acl_remove app, env, user, :cap
      server.acl_find(app, env, user).should eq []
    end

    it 'should remove actions to the current acl' do
      server.acl_add app, env, user, :cap
      server.acl_add app, env, user, :recipes
      server.acl_remove app, env, user, :cap
      server.acl_find(app, env, user).should eq [:recipes]
    end

    it 'should not fail if action is not present' do
      server.acl_remove app, env, user, :cap
      server.acl_find(app, env, user).should be_nil
    end
  end

  describe 'acl_allow?' do
    it 'should return false if no acl for the given user' do
      server.acl_allow?(app, env, user, :cap).should be_false
    end

    it 'should return false if the user do not exists' do
      server.acl_allow?(app, env, nil, :cap).should be_false
    end

    it 'should return false in the current acl does not include the given action' do
      server.acl_add app, env, user, :recipes
      server.acl_allow?(app, env, user, :cap).should be_false
    end

    it 'should return true if the acl include the given action' do
      server.acl_add app, env, user, :cap
      server.acl_allow?(app, env, user, :cap).should be_true
    end

    it 'should return trur for any action if the acl include a wildcard' do
      server.acl_add app, env, user, :*
      server.acl_allow?(app, env, user, :cap).should be_true
      server.acl_allow?(app, env, user, :recipes).should be_true
    end
  end
end
