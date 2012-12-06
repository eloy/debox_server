require 'spec_helper'

describe '/v1/recipes/:app/:env/destroy' do


  it 'should destroy the recipe if exists' do
    login_user
    server = FakeServer.new
    server.create_recipe('test', :staging, 'sample content')
    server.create_recipe('test', :production, 'sample content')
    post "/v1/recipes/test/staging/destroy"
    last_response.should be_ok
    server.recipes_list('test').should eq ['production']
  end
end
