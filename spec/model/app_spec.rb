require 'spec_helper'

describe App do
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }
  it { should have_many :recipes }
end

describe 'App#recipe_names' do
  it 'should return an array with the names for the app recipes' do
    app = create :app
    recipe_1 = create :recipe, app: app
    recipe_2 = create :recipe, app: app
    other = create :recipe
    app.recipe_names.should eq [recipe_1.name, recipe_2.name]
  end
end

describe 'App::find_by_name_or_create' do
  it 'should return app if exists' do
    app = create :app, name: 'app'
    App.find_by_name_or_create('app').should eq app
    App.count.should eq 1
  end

  it 'should create a new app if doesnt exists' do
    app = App.find_by_name_or_create('app')
    app.name.should eq 'app'
    App.count.should eq 1
  end
end
