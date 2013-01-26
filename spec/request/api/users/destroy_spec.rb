require 'spec_helper'

describe '/v1/users/destroy' do

  it 'should fail without auth' do
    login_as_user
    user = create_user
    delete "/v1/users/destroy", user: user.email
    last_response.status.should eq 403
  end

  it 'should destroy the user if exists' do
    admin = create_admin
    login_as_admin admin
    user = create_user
    delete "/v1/users/destroy", user: user.email
    last_response.should be_ok
    server.users_list.should eq [admin.email]
  end
end
