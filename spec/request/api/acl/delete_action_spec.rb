require 'spec_helper'

describe 'POST /v1/acl/role/' do

  it 'should fail if logged user is not an admin' do
    user = create_user
    server.create_recipe('test', 'prod', 'content')
    login_as_user user
    delete "/v1/acl/actions/test", user: user.email, action: 'cap'
    last_response.status.should eq 403
    user.permissions.should be_empty
  end

  context 'withount env' do
    it 'should remove the role to the user' do
      user = create_user
      recipe = server.create_recipe('test', 'prod', 'content')
      create :permission, user: user, recipe: recipe, action: 'cap'
      login_as_admin
      delete "/v1/acl/actions/test", user: user.email, action: 'cap'
      last_response.should be_ok
      last_response.body.should eq 'OK'
      user.permissions.should be_empty
    end
  end

  context 'with env' do
    it 'should remove the role to the user' do
      user = create_user
      recipe = server.create_recipe('test', 'prod', 'content')
      create :permission, user: user, recipe: recipe, action: 'cap'
      login_as_admin
      delete "/v1/acl/actions/test/prod", user: user.email, action: 'cap'
      last_response.should be_ok
      last_response.body.should eq 'OK'
      user.permissions.should be_empty
    end
  end
end
