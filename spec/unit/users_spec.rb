require 'spec_helper'

describe 'DeboxServer::Users#add_users' do
  it 'should add a user to the db' do
    user_data = server.add_user('test@indeos.es', 'password')
    user = User.first
    user.email.should eq 'test@indeos.es'
  end
end

describe 'DeboxServer::Users#login_user' do
  it 'should return false if the user does not exists' do
    server.login_user('invalid@indeos.es', 'password').should be_false
  end

  it 'should return the user data if the user exists' do
    server.add_user('test@indeos.es', 'password')
    data = server.login_user('test@indeos.es', 'password')
    data.should_not be_false
    data.password.should eq hash_str 'password'
  end
end
