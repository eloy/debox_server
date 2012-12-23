require 'spec_helper'

describe '/v1/recipds/:app/:env/new' do
  it 'should create a new config file with the content of the template' do
    login_user
    get '/v1/recipes/test_app/production/new'
    last_response.should be_ok
    last_response.body.should match 'test_app'
    last_response.body.should match 'PRODUCTION'
  end
end
