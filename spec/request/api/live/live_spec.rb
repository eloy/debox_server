require 'spec_helper'

feature 'live', js: true do

  it 'should stream live log' do
    server.create_recipe('test', 'production', 'mock')
    admin = create_admin
    login_as_user! admin

    visit '/v1/cap/test/production?task=deploy'
    visit '/v1/live/log/test/production'

    page.should have_content '1 elefantes'
    page.should have_content '5 elefantes'
  end

  it 'should show notice if not running' do
    server.create_recipe('test', 'production', 'mock')
    admin = create_admin
    login_as_user! admin
    visit '/v1/live/log/test/production'
    page.should have_content 'Job not running'
  end


 end
