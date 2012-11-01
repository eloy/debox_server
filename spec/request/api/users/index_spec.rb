require 'spec_helper'

describe '/api/users' do
  it 'should revceive a users list' do
    create_user 'test@debox.com'
    get '/api/users'
    last_response.should be_ok
    last_response.body.should eq ['test@debox.com'].to_json
  end
end
