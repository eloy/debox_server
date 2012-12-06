require 'spec_helper'

describe '/v1/recipes/:app/:env/show' do
  it 'should return the file content' do
    login_user
    server = FakeServer.new
    server.create_recipe('test_app', :production, 'this is the first content')
    get '/v1/recipes/test_app/production/show'
    last_response.should be_ok
    last_response.body.should eq 'this is the first content'
  end
end
