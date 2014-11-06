require 'spec_helper'

describe '/v1/logs/:app/:env' do

  it 'should fail without authorization' do
    server.create_recipe('test', 'production', 'content')
    login_as_user
    get '/v1/logs/test/production'
    last_response.status.should eq 403
  end

  it 'should return all the logs' do
    out = OpenStruct.new success: true, buffer: 'Some log content', error: 'Log result'
    server.create_recipe('test', 'production', 'content')
    job = stubbed_job 'test', 'production', 'deploy', out
    login_as_admin
    get '/v1/logs/test/production'

    last_response.should be_ok
    data = JSON.parse last_response.body, symbolize_names: true
    saved = data.first
    saved[:error].should eq 'Log result'
    saved[:success].should eq true
  end

  it 'should set default env if not set and only one available' do
    out = OpenStruct.new success: true, buffer: 'Some log content', error: 'Log result'
    server.create_recipe('test', 'production', 'content')
    job = stubbed_job 'test', 'production', 'deploy', out

    login_as_admin
    get '/v1/logs/test'
    last_response.should be_ok
    data = JSON.parse last_response.body, symbolize_names: true
    saved = data.first
    saved[:error].should eq 'Log result'
    saved[:success].should eq true
  end

end
