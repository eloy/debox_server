require 'spec_helper'

describe DeboxServer::Recipes do

  let(:app) { 'test_app'}
  let(:content) { 'Some fake content' }

  describe 'DeboxServer::Recipes#recipe_content' do
    it 'should return a new recipe with defaults vaules' do
      server.create_recipe(app, :production, content)
      server.recipe_content(app, :production).should eq content
    end

    it 'should create an app if not present' do
      server.create_recipe(app, :production, content)
      server.app_exists?(app).should be_true
    end
  end

  describe 'DeboxServer::Recipes#create_recipe' do
    it 'should create the recipe if not exist' do
      server.create_recipe(app, :production, content).should be_true
      server.recipe_content(app, :production).should eq content
    end

    it 'should fail if already exists' do
      server.create_recipe(app, :production, content)
      server.create_recipe(app, :production, 'try to overwrite').should be_false
      server.recipe_content(app, :production).should eq content
    end
  end

  describe 'DeboxServer::Recipes#update_recipe' do
    it 'should update the recipe if exist' do
      server.create_recipe(app, :production, 'this is the first content')
      server.update_recipe(app, :production, content)
      server.recipe_content(app, :production).should eq content

    end

    it 'should fail if already exists' do
      server.create_recipe(app, :production, content)
      server.create_recipe(app, :production, 'try to overwrite').should be_false
      server.recipe_content(app, :production).should eq content
    end

  end

  describe 'DeboxServer::Recipes#new_recipe' do
    it 'should return a new recipe with defaults vaules' do
      content = server.new_recipe app, :production
      content.should match app
      content.should match 'PRODUCTION'
    end
  end

  describe 'DeboxServer::Recipes#recipes_destroy' do
    it 'should destroy the recipe if exists' do
      staging = server.create_recipe('test', :staging, 'sample content')
      production = server.create_recipe('test', :production, 'sample content')
      server.recipes_destroy('test', 'staging')
      app = App.find_by_name 'test'
      app.recipes.should eq [production]
    end
  end
end
