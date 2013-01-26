require 'spec_helper'

describe '/v1/logs/:app/:env' do

  it 'should fail without authorization' do
    server.create_recipe('test', 'production', 'content')
    login_as_user
    get '/v1/logs/test/production'
    last_response.status.should eq 403
  end

  it 'should return all the logs' do
    time = DateTime.now
    out = OpenStruct.new time: time, success: true, buffer: 'Some log content', error: 'Log result'
    server.create_recipe('test', 'production', 'content')
    job = stubbed_job 'test', 'production', 'deploy', out
    job.save_log

    login_as_admin
    get '/v1/logs/test/production'

    last_response.should be_ok
    data = JSON.parse last_response.body, symbolize_names: true
    saved = data.first
    DateTime.parse(saved[:time]).to_s.should eq time.to_s
    saved[:error].should eq 'Log result'
    saved[:status].should eq 'success'
  end

  it 'should set default env if not set and only one available' do
    time = DateTime.now
    out = OpenStruct.new time: time, success: true, buffer: 'Some log content', error: 'Log result'
    server.create_recipe('test', 'production', 'content')
    job = stubbed_job 'test', 'production', 'deploy', out
    job.save_log

    login_as_admin
    get '/v1/logs/test'
    last_response.should be_ok
    data = JSON.parse last_response.body, symbolize_names: true
    saved = data.first
    DateTime.parse(saved[:time]).to_s.should eq time.to_s
    saved[:error].should eq 'Log result'
    saved[:status].should eq 'success'
  end

end
