require 'spec_helper'

describe DeboxServer::Recipes do

  let(:app) { 'test_app'}
  let(:recipe_file) {File.join recipes_app_dir!(app), "production.rb"}
  let(:content) { 'Some fake content' }

  describe 'DeboxServer::Recipes#recipe_exists?' do
    it 'should return false if recipe does not exists' do
      server = FakeServer.new
      server.recipe_exists?(app, :production).should be_false
    end

    it 'should return true if recipe exists' do
      server = FakeServer.new
      FileUtils.touch recipe_file
      server.recipe_exists?(app, :production).should be_true
    end
  end

  describe 'DeboxServer::Recipes#create_recipe' do
    it 'should create the recipe if not exist' do
      server = FakeServer.new
      server.create_recipe(app, :production, content).should be_true
      server.recipe_exists?(app, :production).should be_true
      File.open(recipe_file).read.should eq content
    end

    it 'should fail if already exists' do
      server = FakeServer.new
      server.create_recipe(app, :production, content)
      server.create_recipe(app, :production, 'try to overwrite').should be_false
      File.open(recipe_file).read.should eq content
    end
  end

  describe 'DeboxServer::Recipes#update_recipe' do
    it 'should update the recipe if exist' do
      server = FakeServer.new
      server.create_recipe(app, :production, 'this is the first content')
      server.update_recipe(app, :production, content).should be_true
      File.open(recipe_file).read.should eq content

    end

    it 'should fail if already exists' do
      server = FakeServer.new
      server.create_recipe(app, :production, content)
      server.create_recipe(app, :production, 'try to overwrite').should be_false
      File.open(recipe_file).read.should eq content
    end

  end

  describe 'DeboxServer::Recipes#new_recipe' do
    it 'should return a new recipe with defaults vaules' do
      server = FakeServer.new
      content = server.new_recipe app, :production
      content.should match app
      content.should match 'PRODUCTION'
    end
  end


  describe 'DeboxServer::Recipes#recipe_content' do
    it 'should return a new recipe with defaults vaules' do
      server = FakeServer.new
      server.create_recipe(app, :production, content)
      server.recipe_content(app, :production).should eq content
    end
  end

end
