require 'spec_helper'

describe '/v1/cap/:app' do

  before :each do
    @app = 'test'
    @env = 'production'
  end

  it 'should fail withhout access' do
    login_as_user
    server.create_recipe(@app, @env, 'content')
    get '/v1/cap/test/production?task=deploy'
    last_response.status.should eq 403
  end

  it 'should deal with invalid @app' do
    login_as_admin
    get '/v1/cap/test/production?task=deploy'
    last_response.should_not be_ok
    last_response.body.should match "Couldn't find App"
  end

  it 'should set default task if not setted' do
    server.create_recipe(@app, @env, 'content')
    login_as_admin

    get "/v1/cap/#{@app}/#{@env}"

    last_response.should be_ok
    job = JSON.parse last_response.body, symbolize_names: true
    job[:app].should eq @app
    job[:env].should eq @env
    job[:task].should eq 'deploy'
  end

  it 'should use the given task if present' do
    server.create_recipe(@app, @env, 'content')
    login_as_admin
    get "/v1/cap/#{@app}?task=node:restart"
    last_response.should be_ok
    job = JSON.parse last_response.body, symbolize_names: true
    job[:app].should eq @app
    job[:env].should eq @env
    job[:task].should eq 'node:restart'
  end

  it 'should fail without env param and more than one env' do
    server.create_recipe(@app, @env, 'content')
    server.create_recipe(@app, 'other', 'content')
    login_as_admin
    get "/v1/cap/#{@app}"
    last_response.should_not be_ok
    last_response.body.should match 'Enviromnment must be set'
  end

  it 'should fail without env param and invalid app' do
    login_as_admin
    get "/v1/cap/#{@app}"
    last_response.should_not be_ok
    last_response.body.should match "Couldn't find App"
  end

  it 'should set default env if not setted' do
    server.create_recipe(@app, @env, 'content')
    login_as_admin
    get "/v1/cap/#{@app}"
    last_response.should be_ok
    job = JSON.parse last_response.body, symbolize_names: true
    job[:app].should eq @app
    job[:env].should eq @env
    job[:task].should eq 'deploy'
  end

  it 'should deal with invalid recipe content' do
    server.create_recipe(@app, @env, 'load "invalid"')
    login_as_admin
    get "/v1/cap/#{@app}/#{@env}"

    last_response.should be_ok

    job = JSON.parse last_response.body, symbolize_names: true
    job[:app].should eq @app
    job[:env].should eq @env
    job[:task].should eq 'deploy'
  end
end
