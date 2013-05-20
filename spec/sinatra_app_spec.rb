require_relative '../sinatra_app'
require 'capybara/rspec'

Capybara.app = SinatraApp

describe SinatraApp, type: :feature do
  it "can register a user" do
    SinatraApp.registrations.length.should be 0
    visit '/register'
    fill_in 'username', with: 'ben'
    fill_in 'email', with: 'ben@example.com'
    click_button 'Submit'

    SinatraApp.registrations.length.should be 1
  end
end
