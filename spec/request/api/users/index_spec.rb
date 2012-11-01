require 'spec_helper'

describe '/api/users' do
  it 'should return unauthorized without login' do
    create_user 'test@debox.com'
    get '/api/users'
    last_response.status.should eq 401
  end


  it 'should revceive a users list' do
    user = create_user 'test@debox.com'
    login_user user

    get '/api/users'
    last_response.should be_ok
    last_response.body.should eq ['test@debox.com'].to_json
  end
end
