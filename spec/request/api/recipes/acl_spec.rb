require 'spec_helper'

describe 'acl for /v1/recipes' do
  it 'should fail without authorization' do
    login_as_user
    server.create_recipe('test_app', :production, 'this is the first content')
    get '/v1/recipes/test_app/production'
    last_response.status.should eq 403
  end
end
