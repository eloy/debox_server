require 'spec_helper'

describe User do
  it { should validate_presence_of :email }
end

describe 'User#create_api_token callback' do
  it 'should create api_token for new users' do
    user = create :user
    user.api_key.should_not be_nil
  end
end

describe 'User#password=' do
  it 'should crypt password' do
    user = build_stubbed :user, password: 'secret'
    user.password.should eq '5ebe2294ecd0e0f08eab7690d2a6ee69'
  end
end


describe 'User#can?' do
  it 'should return false if no acl for the given user' do
    user = create :user
    recipe = create :recipe
    user.can?(:cap, on: recipe).should be_false
  end

  it 'should return false in the current permissions does not include the given action' do
    user = create :user
    recipe = create :recipe
    create :permission, user: user, recipe: recipe, action: 'logs'
    user.can?(:cap, on: recipe).should be_false
  end

  it 'should return true if the permissions include the given action' do
    user = create :user
    recipe = create :recipe
    create :permission, user: user, recipe: recipe, action: 'cap'
    user.can?(:cap, on: recipe).should be_true
  end
  it 'should return trur for any action if the user is admin' do
    user = create :admin
    recipe = create :recipe
    user.can?(:cap, on: recipe).should be_true
  end

  it 'should return trur for any action if the permissions include a wildcard' do
    user = create :user
    recipe = create :recipe
    create :permission, user: user, recipe: recipe, action: '*'
    user.can?(:cap, on: recipe).should be_true
  end
end
