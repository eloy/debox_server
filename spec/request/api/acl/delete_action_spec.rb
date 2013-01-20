require 'spec_helper'

describe 'POST /v1/acl/role/' do

  it 'should fail if logged user is not an admin' do
    user = create_user
    server.create_recipe('test', 'prod', 'content')
    login_as_user user
    delete "/v1/acl/actions/test", user: user.email, action: 'cap'
    last_response.status.should eq 401
    server.acl_find('test', 'prod', user).should be_nil
  end

  context 'withount env' do
    it 'should remove the role to the user' do
      user = create_user
      server.create_recipe('test', 'prod', 'content')
      server.acl_add 'test', 'prod', user, :cap
      login_as_admin
      delete "/v1/acl/actions/test", user: user.email, action: 'cap'
      last_response.should be_ok
      last_response.body.should eq 'OK'
      server.acl_find('test', 'prod', user).should eq []
    end
  end

  context 'with env' do
    it 'should remove the role to the user' do
      user = create_user
      server.create_recipe('test', 'prod', 'content')
      server.acl_add 'test', 'prod', user, :cap
      login_as_admin
      delete "/v1/acl/actions/test/prod", user: user.email, action: 'cap'
      last_response.should be_ok
      last_response.body.should eq 'OK'
      server.acl_find('test', 'prod', user).should eq []
    end
  end
end
