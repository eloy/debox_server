require 'spec_helper'

describe '/v1/users' do
  it 'should return unauthorized without login' do
    get '/v1/users'
    last_response.status.should eq 401
  end


  it 'should revceive a users list' do
    user = create_admin
    login_as_admin user

    get '/v1/users'
    last_response.should be_ok
    last_response.body.should eq [user.email].to_json
  end
end
