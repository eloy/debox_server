require 'spec_helper'

describe '/api/recipes/:app/:env/show' do
  it 'should return the file content' do
    login_user
    server = FakeServer.new
    server.create_recipe('test_app', :production, 'this is the first content')
    post '/api/recipes/test_app/production/update', content: 'updated content'
    last_response.should be_ok
    server.recipe_content('test_app', 'production').should eq 'updated content'
  end
end
