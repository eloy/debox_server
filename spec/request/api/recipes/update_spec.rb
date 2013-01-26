require 'spec_helper'

describe '/v1/recipes/:app/:env/show' do
  it 'should return the file content' do
    login_as_admin
    server = FakeServer.new
    server.create_recipe('test_app', :production, 'this is the first content')
    put '/v1/recipes/test_app/production', content: 'updated content'
    last_response.should be_ok
    server.recipe_content('test_app', 'production').should eq 'updated content'
  end
end
