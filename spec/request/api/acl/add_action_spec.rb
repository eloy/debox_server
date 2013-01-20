require 'spec_helper'

describe 'POST /v1/acl/role/' do
  context 'withount env' do
    it 'should add the role to the user' do
      user = create_user
      server.create_recipe('test', 'prod', 'content')
      login_as_admin
      post "/v1/acl/actions/test", user: user.email, action: 'cap'
      last_response.status.should eq 201 # Created
      last_response.body.should eq 'OK'
      server.acl_find('test', 'prod', user).should eq [:cap]
    end
  end

  context 'with env' do
    it 'should add the role to the user' do
      user = create_user
      server.create_recipe('test', 'prod', 'content')
      login_as_admin
      post "/v1/acl/actions/test/prod", user: user.email, action: 'cap'
      last_response.status.should eq 201 # Created
      last_response.body.should eq 'OK'
      server.acl_find('test', 'prod', user).should eq [:cap]
    end
  end
end
