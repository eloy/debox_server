require 'spec_helper'

describe '/api/recipes/:app/:env/create' do
  it 'should create a config file with given content' do
    login_user
    post '/api/recipes/test/production/create', content: 'some content'
    last_response.should be_ok
    server = FakeServer.new
    server.recipe_content('test', 'production').should eq 'some content'
  end
end
