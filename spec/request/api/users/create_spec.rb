require 'spec_helper'

describe '/v1/users/create' do

  it 'should fail without login' do
    post '/v1/users/create', user: 'new@indeos.es', password: 'secret'
    last_response.status.should eq 401
  end

  it 'should fail without auth' do
    login_as_user
    post '/v1/users/create', user: 'new@indeos.es', password: 'secret'
    last_response.status.should eq 403
  end

  it 'should create a user with valid credentials' do
    login_as_admin
    post '/v1/users/create', user: 'new@indeos.es', password: 'secret'
    last_response.status.should eq 201
    last_response.body.should eq 'ok'
    find_user('new@indeos.es').should_not be_nil
  end
end
