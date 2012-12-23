require 'spec_helper'

describe '/v1/deploy/:app/:env' do

  it 'should deal with invalid app' do
    login_user
    get '/v1/deploy/test/production'
    last_response.should_not be_ok
    last_response.body.should match 'App not found'
  end

  it 'should deal with invalid recipe' do
    app = 'test'
    env = 'production'

    server = FakeServer.new
    server.create_recipe(app, env, 'load "invalid"')
    login_user
    get "/v1/deploy/#{app}/#{env}"

    last_response.should be_ok

    job = JSON.parse last_response.body, symbolize_names: true
    job[:app].should eq app
    job[:env].should eq env
    job[:task].should eq 'deploy'
  end

end
