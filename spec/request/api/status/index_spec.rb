require 'spec_helper'
describe '/v1/status' do
  it 'should return jobs queue status' do

    server.create_recipe('foo', 'production', 'content')
    server.create_recipe('bar', 'production', 'content')
    login_as_admin

    get '/v1/cap/foo/production?task=deploy'
    get '/v1/cap/foo/production?task=deploy'
    get '/v1/cap/bar/production?task=deploy'
    get '/v1/cap/bar/production?task=deploy'

    get '/v1/status'
    # p last_response.status
    # last_response.should be_ok
    status = JSON.parse last_response.body, symbolize_names: true
    # p status
  end
end
