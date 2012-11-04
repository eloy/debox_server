require 'spec_helper'

describe DeboxServer::Apps do

  describe 'DeboxServer::Apps#apps_create' do
    it 'should create an app' do
      server = DeboxServer::Core.new
      server.apps_create('test').should be_true
      server.apps_list.should include 'test'
    end

    it 'should return false if the app exists' do
      server = DeboxServer::Core.new
      server.apps_create 'test'
      server.apps_create('test').should be_false
    end

  end


  describe 'DeboxServer::Apps#apps_exists?' do
    it 'should return false if the app does not exists' do
      server = DeboxServer::Core.new
      server.apps_exists?('test').should be_false
    end

    it 'should return true if the app exists' do
      server = DeboxServer::Core.new
      server.apps_create 'test'
      server.apps_exists?('test').should be_true
    end
  end


  describe 'DeboxServer::Apps#apps_list' do
    it 'should return all the registered apps' do
      server = DeboxServer::Core.new
      server.apps_create 'test'
      server.apps_create 'test2'
      server.apps_list.should eq ['test', 'test2']
    end
  end

end
