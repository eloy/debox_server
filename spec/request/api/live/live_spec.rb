require 'spec_helper'

feature 'live', js: true do

  xit 'should stream live log' do
    server.create_recipe('test', 'production', 'mock')
    admin = create_admin
    login_as_user! admin

    visit '/v1/cap/test/production?task=deploy'
    job = JSON.parse page.source, symbolize_names: true
    visit "/v1/live/log/job/#{job[:job_id]}"

    page.should have_content '1 elefantes'
    page.should have_content '5 elefantes'
  end

  xit 'should show notice if not running' do
    admin = create_admin
    login_as_user! admin
    visit "/v1/live/log/job/666"
    page.should have_content 'Job not running'
  end


 end
