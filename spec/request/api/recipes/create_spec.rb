require 'spec_helper'

describe 'post /v1/recipes/:app/:env' do
  it 'should create a config file with given content' do
    login_as_admin
    post '/v1/recipes/test/production', content: 'some content'
    last_response.status.should eq 201
    server = FakeServer.new
    server.recipe_content('test', 'production').should eq 'some content'
  end
end
