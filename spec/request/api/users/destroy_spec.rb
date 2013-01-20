require 'spec_helper'

describe '/v1/users/destroy' do

  it 'should destroy the recipe if exists' do
    user = create_admin
    login_as_admin user
    server = FakeServer.new
    other_user = create_admin email: 'other@indeos.es'
    delete "/v1/users/destroy", user: 'other@indeos.es'
    last_response.should be_ok
    server.users_list.should eq [user.email]
  end
end
