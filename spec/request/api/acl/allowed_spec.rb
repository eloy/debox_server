require 'spec_helper'

describe '/v1/acl/:app/:env/allow' do

  it 'should return 403 Forbidden if the user is not allowed' do
    server.create_recipe('test', :production, 'content')
    login_as_user
    get "/v1/acl/allowed/test/production", action: 'cap'
    last_response.should_not be_ok
    last_response.status.should eq 403
    last_response.body.should match "User is not allowed to run this action"
  end

  it 'should return YES if the user is allowed' do
    user = create_user
    server.create_recipe('test', 'prod', 'content')
    server.acl_add 'test', 'prod', user, :cap
    login_as_user user
    get "/v1/acl/allowed/test/prod", action: 'cap'
    last_response.should be_ok
    last_response.body.should match "YES"
  end

  it 'should use the right env' do
    user = create_user
    server.create_recipe('test', 'prod', 'content')
    server.acl_add 'test', 'prod', user, :cap
    login_as_user user
    get "/v1/acl/allowed/test", action: 'cap'
    last_response.should be_ok
    last_response.body.should match "YES"
  end

  it "user can't override user param" do
    user = create_user
    other_user = create_user email: 'other@indeos.es'
    server.create_recipe('test', 'prod', 'content')
    server.acl_add 'test', 'prod', other_user, :cap
    login_as_user user
    get "/v1/acl/allowed/test", action: 'cap', user: other_user.email
    last_response.status.should eq 403
  end

  it "admins can override user param" do
    admin = create_admin
    other_user = create_user email: 'other@indeos.es'
    server.create_recipe('test', 'prod', 'content')
    server.acl_add 'test', 'prod', other_user, :cap
    login_as_admin admin
    get "/v1/acl/allowed/test", action: 'cap', user: other_user.email
    last_response.should be_ok
  end

end
