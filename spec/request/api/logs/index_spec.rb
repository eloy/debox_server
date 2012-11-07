require 'spec_helper'

describe '/api/logs/:app/:env' do
  it 'should return all the logs' do
    time = DateTime.now
    out = OpenStruct.new time: time, success: true, buffer: 'Some log content', result: 'Log result'
    server = DeboxServer::Core.new
    server.save_deploy_log 'test', 'production', 'deploy', out
    login_user
    get '/api/logs/test/production'
    last_response.should be_ok
    data = JSON.parse last_response.body, symbolize_names: true
    saved = data.first
    DateTime.parse(saved[:time]).to_s.should eq time.to_s
    saved[:success].should be_true
    saved[:log].should eq 'Some log content'
    saved[:result].should eq 'Log result'
  end
end
