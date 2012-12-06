require 'spec_helper'

describe '/v1/recipes/:app/' do
  it 'should return an empty array without recipes' do
    login_user
    server = FakeServer.new
    get '/v1/recipes/test'
    last_response.should be_ok
    last_response.body.should eq [].to_json
  end


  it 'should return current recipes if any' do
    login_user
    server = FakeServer.new
    app = 'test'
    server.create_recipe(app, :staging, 'sample content')
    server.create_recipe(app, :production, 'sample content')
    get "/v1/recipes/#{app}"
    last_response.should be_ok
    last_response.body.should eq ['staging', 'production'].to_json
  end
end
