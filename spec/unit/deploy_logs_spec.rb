require 'spec_helper'

describe 'DeboxServer::DeployLogs#save_deploy_logs' do
  it 'should store the given log data' do
    time = DateTime.now
    out = OpenStruct.new time: time, success: true, buffer: 'Some log content', result: 'Log result'
    server = DeboxServer::Core.new
    server.save_deploy_log 'test', 'production', 'deploy', out
    saved = server.deployer_logs_at 'test', 'production', 0
    DateTime.parse(saved[:time]).to_s.should eq time.to_s
    saved[:success].should be_true
    saved[:log].should eq 'Some log content'
    saved[:result].should eq 'Log result'
  end

  it 'should store only max number of logs' do
    time = DateTime.now
    out = OpenStruct.new time: time, success: true, buffer: 'Some log content', result: 'Log result'
    last = OpenStruct.new time: time, success: true, buffer: 'Last log content', result: 'Log result'
    server = DeboxServer::Core.new
    app = 'test'
    env = 'production'
    DeboxServer::DeployLogs::MAX_LOGS_COUNT.times do
      server.save_deploy_log app, env, 'deploy', out
    end

    server.save_deploy_log app, env, 'deploy', last

    server.deployer_logs_count(app, env).should eq DeboxServer::DeployLogs::MAX_LOGS_COUNT
    saved_last = server.deployer_logs_last app, env
    saved_last[:log].should eq 'Last log content'
  end

end


describe 'DeboxServer::DeployLogs#deployer_logs' do
  it 'should return current logs if present' do
    time = DateTime.now
    out = OpenStruct.new time: time, success: true, buffer: 'Some log content', result: 'Log result'
    server = DeboxServer::Core.new
    server.save_deploy_log 'test', 'production', 'deploy', out
    logs = server.deployer_logs 'test', 'production'
    saved = logs.first
    DateTime.parse(saved[:time]).to_s.should eq time.to_s
    saved[:success].should be_true
    saved[:log].should eq 'Some log content'
    saved[:result].should eq 'Log result'
  end
end
