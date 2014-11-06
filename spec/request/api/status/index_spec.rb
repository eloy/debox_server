require 'spec_helper'
describe '/v1/status' do
  # TODO: Finish it
  xit 'should return jobs queue status' do
    login_as_admin
    get '/v1/status'
    last_response.should be_ok
    status = JSON.parse last_response.body, symbolize_names: true
  end
end
