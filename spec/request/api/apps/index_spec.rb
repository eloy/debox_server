require 'spec_helper'
describe '/api/apps' do
  it 'should return an empty array without apps' do
    login_user
    server = FakeServer.new
    get '/api/apps'
    last_response.should be_ok
    last_response.body.should eq [].to_json
  end


  it 'should return current apps if any' do
    login_user
    server = FakeServer.new
    server.apps_create('test_app')
    server.apps_create('other_app')
    get '/api/apps'
    last_response.should be_ok
    last_response.body.should eq ['test_app', 'other_app'].to_json
  end
end
