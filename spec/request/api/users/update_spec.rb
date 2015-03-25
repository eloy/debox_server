require 'spec_helper'

describe 'PUT /v1/users/:id' do

  it 'should fail without login' do
    user = create_admin
    put "/v1/users/#{user.id}", user: { password: '1234' }
    last_response.status.should eq 401
  end

  it 'should fail without auth' do
    login_as_user
    user = create_admin
    put "/v1/users/#{user.id}", user: { password: '1234' }
    last_response.status.should eq 403
  end

  it 'should update the user with valid credentials' do
    login_as_admin
    user = create_admin
    put "/v1/users/#{user.id}", user: { password: '1234' }
    puts last_response.body
    last_response.status.should eq 200
  end
end
