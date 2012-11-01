require 'spec_helper'

describe '/api/users/create' do
  it 'should create a user with valid credentials' do
    post '/api/users/create', user: 'new@indeos.es', password: 'secret'
    last_response.should be_ok
    last_response.body.should eq 'ok'
    find_user('new@indeos.es').should_not be_nil
  end
end
