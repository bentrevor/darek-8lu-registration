require_relative '../sinatra_app'
require 'capybara/rspec'

Capybara.app = SinatraApp

describe SinatraApp, type: :feature do
  after :each do
    SinatraApp.registrations = []
  end

  it "can register a user" do
    SinatraApp.registrations.length.should be 0
    register_user "valid", "valid@example.com"

    SinatraApp.registrations.length.should be 1
  end

  it "redirects to a 'success' page after registration" do
    register_user "valid", "valid@example.com"

    page.should have_content "Registration successful!"
  end

  it "only accepts alphanumeric characters for the name" do
    assert_invalid_names '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '[', ']', '{', '}', '\\', '|', ';', ':', "'", '"', ',', '.', '<', '>', '?', '/', '`', '~', '-', '_', '=', '+'
  end

  def assert_invalid_names( *characters )
    characters.each do |character|
      name = "invalid" << character
      register_user name, "valid@example.com"
      SinatraApp.registrations.length.should be 0
    end
  end

  def register_user( name, email )
    visit '/register'
    fill_in 'username', with: name
    fill_in 'email',    with: email
    click_button 'Submit'
  end
end
