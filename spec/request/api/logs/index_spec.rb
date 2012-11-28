require 'spec_helper'

describe '/api/logs/:app/:env' do
  it 'should return all the logs' do
    time = DateTime.now
    out = OpenStruct.new time: time, success: true, buffer: 'Some log content', error: 'Log result'
    server = DeboxServer::Core.new

    job = stubbed_job 'test', 'production', 'deploy', out
    job.save_log

    login_user
    get '/api/logs/test/production'
    last_response.should be_ok
    data = JSON.parse last_response.body, symbolize_names: true
    saved = data.first
    DateTime.parse(saved[:time]).to_s.should eq time.to_s
    saved[:error].should eq 'Log result'
    saved[:status].should eq 'success'
  end

  it 'should return invalid if log does not exists' do
    time = DateTime.now
    out = OpenStruct.new time: time, success: true, buffer: 'Some log content', error: 'Log result'
    server = DeboxServer::Core.new
    login_user
    get '/api/logs/test/production/last'
    last_response.should_not be_ok
    last_response.body.should match 'Log not found'
  end

end
