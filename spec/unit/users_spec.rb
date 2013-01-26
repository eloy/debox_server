require 'spec_helper'

describe 'DeboxServer::Users#add_users' do
  it 'should add a user to the db' do
    app = FakeServer.new
    user_data = app.add_user('test@indeos.es', 'password')
    user_data.password.should eq hash_str 'password'
  end
end

describe 'DeboxServer::Users#find_user' do
  it 'should find a user by email if exists' do
    app = FakeServer.new
    user_data = app.add_user('test@indeos.es', 'password')
    found = app.find_user('test@indeos.es')
    found.should_not be_false
    found.email.should eq 'test@indeos.es'
    found.password.should eq hash_str 'password'
    found.admin.should be_false
  end
end

describe 'DeboxServer::Users#users_config' do
  it 'should return an empty object if empty' do
    app = FakeServer.new
    expected = { }
    app.users_config.should eq expected
  end
end

describe 'DeboxServer::Users#login_user' do
  it 'should return false if the user does not exists' do
    app = FakeServer.new
    app.login_user('invalid@indeos.es', 'password').should be_false
  end

  it 'should return the user data if the user exists' do
    app = FakeServer.new
    app.add_user('test@indeos.es', 'password')
    data = app.login_user('test@indeos.es', 'password')
    data.should_not be_false
    data.password.should eq hash_str 'password'
  end
end

describe 'DeboxServer::Users::users_make_admin!' do
  it 'should add the admin flag to the user and keep other details' do

    server.add_user('test@indeos.es', 'password')
    server.users_make_admin! 'test@indeos.es'

    user = server.find_user('test@indeos.es')
    user.email.should eq 'test@indeos.es'
    user.password.should eq hash_str 'password'
    user.admin.should be_true
  end

  it 'should return false if the user does not exists' do
    server.users_make_admin!('test@indeos.es').should be_false
  end
end

describe 'DeboxServer::Users::users_remove_admin!' do
  it 'should remove the admin flag to the user and keep other details' do

    server.add_user('test@indeos.es', 'password', admin: true)
    server.users_remove_admin! 'test@indeos.es'
    user = server.find_user('test@indeos.es')
    user.email.should eq 'test@indeos.es'
    user.password.should eq hash_str 'password'
    user.admin.should be_false
  end

  it 'should return false if the user does not exists' do
    server.users_remove_admin!('test@indeos.es').should be_false
  end
end
