require 'spec_helper'

describe '/v1/recipes/:app/:env/destroy' do

  it 'should destroy the recipe if exists' do
    login_as_admin
    app = create :app, name: 'test'
    create :recipe, app: app, name: 'staging'
    create :recipe, app: app, name: 'production'
    delete "/v1/recipes/test/staging"
    last_response.should be_ok
    app.recipe_names.should eq ['production']
  end

end
