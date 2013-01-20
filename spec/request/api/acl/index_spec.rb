require 'spec_helper'

describe '/v1/acl/actions' do


  context 'withount env' do
    it 'should remove the role to the user' do
      user = create_user
      server.create_recipe('test', 'prod', 'content')
      server.acl_add 'test', 'prod', user, :cap
      login_as_user user
      get "/v1/acl/actions/test"
      last_response.should be_ok
      last_response.body.should eq [:cap].to_json
    end
  end

  context 'with env' do
    it 'should remove the role to the user' do
      user = create_user
      server.create_recipe('test', 'prod', 'content')
      server.acl_add 'test', 'prod', user, :cap
      login_as_user user
      get "/v1/acl/actions/test/prod"
      last_response.should be_ok
      last_response.body.should eq [:cap].to_json
    end
  end

  it "Users can't set user param" do
    user = create_user
    other_user = create_user
    server.create_recipe('test', 'prod', 'content')
    server.acl_add 'test', 'prod', other_user, :cap
    login_as_user user
    get "/v1/acl/actions/test/prod", user: other_user.email
    last_response.should be_ok
    last_response.body.should eq [].to_json
  end

  it "Admins can set user param" do
    user = create_admin
    other_user = create_user
    server.create_recipe('test', 'prod', 'content')
    server.acl_add 'test', 'prod', other_user, :cap
    login_as_user user
    get "/v1/acl/actions/test/prod", user: other_user.email
    last_response.should be_ok
    last_response.body.should eq [:cap].to_json
  end


end
