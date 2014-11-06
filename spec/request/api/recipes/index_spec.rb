require 'spec_helper'

describe '/v1/recipes/:app/' do
  it 'should return an empty array without recipes' do
    login_as_admin
    app = create :app, name: 'test'
    get '/v1/recipes/test'
    last_response.should be_ok
    last_response.body.should eq [].to_json
  end


  it 'should return current recipes if any' do
    login_as_admin
    app = create :app, name: 'test'
    create :recipe, app: app, name: 'staging'
    create :recipe, app: app, name: 'production'
    get "/v1/recipes/test"
    last_response.should be_ok
    last_response.body.should eq ['staging', 'production'].to_json
  end
end
