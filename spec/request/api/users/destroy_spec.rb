require 'spec_helper'

describe '/api/users/destroy' do


  it 'should destroy the recipe if exists' do
    user = create_user
    login_user user
    server = FakeServer.new
    other_user = create_user 'other@indeos.es'
    post "/api/users/destroy", user: 'other@indeos.es'
    last_response.should be_ok
    server.users_list.should eq [user.email]
  end
end
