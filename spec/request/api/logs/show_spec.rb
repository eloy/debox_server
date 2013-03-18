require 'spec_helper'

describe '/v1/log' do

  it 'should fail without authorization' do
    server.create_recipe('test', 'production', 'content')
    login_as_user
    get '/v1/log/test/production'
    last_response.status.should eq 403
  end

  it 'should return invalid if log does not exists' do
    server.create_recipe('test', 'production', 'content')
    login_as_admin
    get '/v1/log/test/production'
    last_response.should_not be_ok
    last_response.body.should match 'job not found'
  end

  it 'should return log content' do
    out = OpenStruct.new time: DateTime.now, success: true, buffer: 'Some log content', error: 'Log result'
    server.create_recipe('test', 'production', 'content')
    job = stubbed_job 'test', 'production', 'deploy', out

    login_as_admin
    get '/v1/log/test/production'
    last_response.should be_ok
    last_response.body.should match 'Some log content'
  end


  it 'should return use default env if not set' do
    out = OpenStruct.new time: DateTime.now, success: true, buffer: 'Some log content', error: 'Log result'
    server.create_recipe('test', 'production', 'content')
    job = stubbed_job 'test', 'production', 'deploy', out

    login_as_admin
    get '/v1/log/test'
    last_response.should be_ok
    last_response.body.should match 'Some log content'
  end


end
