require 'spec_helper'

describe '/api_key' do

  it 'should return 401 with invalid credentials' do
    get '/v1/api_key'
    last_response.should_not be_ok
    last_response.status.should eq 401
  end

  it 'should return 401 with invalid credentials' do
    get '/v1/api_key', user: 'test@debox.com'
    last_response.should_not be_ok
    last_response.status.should eq 401
  end


  it 'should return token with valid credentials' do
    user = create_user 'test@debox.com'
    get '/v1/api_key', user: 'test@debox.com', password: 'secret'
    last_response.should be_ok
    last_response.body.should eq user.api_key
  end

end
