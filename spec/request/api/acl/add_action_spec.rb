require 'spec_helper'

describe 'POST /v1/acl/role/' do

  it 'should fail if logged user is not an admin' do
    user = create_user
    recipe = server.create_recipe('test', 'prod', 'content')
    login_as_user user
    post "/v1/acl/actions/test", user: user.email, action: 'cap'
    last_response.status.should eq 403
    user.permissions.should be_empty
  end

  context 'withount env' do
    it 'should add the role to the user' do
      user = create_user
      recipe = server.create_recipe('test', 'prod', 'content')
      login_as_admin
      post "/v1/acl/actions/test", user: user.email, action: 'cap'
      last_response.status.should eq 201 # Created
      last_response.body.should eq 'OK'
      permissions = user.permissions_for_recipe recipe
      permissions.first.action.should eq 'cap'
    end
  end

  context 'with env' do
    it 'should add the role to the user' do
      user = create_user
      recipe = server.create_recipe('test', 'prod', 'content')
      login_as_admin
      post "/v1/acl/actions/test/prod", user: user.email, action: 'cap'
      last_response.status.should eq 201 # Created
      last_response.body.should eq 'OK'
      permissions = user.permissions_for_recipe recipe
      permissions.first.action.should eq 'cap'
    end
  end
end
