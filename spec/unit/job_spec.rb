require 'spec_helper'

describe 'DeboxServer::Job#save_logs' do
  it 'should save job logs to redis' do
    out = OpenStruct.new time: DateTime.now, success: true, buffer: 'Some log content', error: 'Log result'
    job = stubbed_job 'test', 'production', 'deploy', out
    job.save_log
    logs = server.deployer_logs 'test', 'production'
    logs.count.should eq 1
    log = logs.first
    log[:error].should eq 'Log result'
    log[:status].should eq 'success'
  end
end
