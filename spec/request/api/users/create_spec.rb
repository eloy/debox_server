require 'spec_helper'

describe '/api/users/create' do

  it 'should fail without login' do
    post '/api/users/create', user: 'new@indeos.es', password: 'secret'
    last_response.status.should eq 401
  end


  it 'should create a user with valid credentials' do
    login_user
    post '/api/users/create', user: 'new@indeos.es', password: 'secret'
    last_response.should be_ok
    last_response.body.should eq 'ok'
    find_user('new@indeos.es').should_not be_nil
  end
end
