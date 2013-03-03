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
