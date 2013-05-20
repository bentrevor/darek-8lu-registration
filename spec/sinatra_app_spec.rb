require_relative '../sinatra_app'
require 'capybara/rspec'

Capybara.app = SinatraApp

describe SinatraApp, type: :feature do
  after :each do
    SinatraApp.registrants = []
  end

  describe "successful registration" do
    it "can register a user" do
      SinatraApp.registrants.length.should be 0
      register_user "valid", "valid@example.com"

      SinatraApp.registrants.length.should be 1
    end

    it "adds a user to a registrant list" do
      register_user "firstname", "firstemail@example.com"
      register_user "secondname", "secondemail@example.com"

      SinatraApp.registrants[0][0].should == "firstname"
      SinatraApp.registrants[0][1].should == "firstemail@example.com"
      SinatraApp.registrants[1][0].should == "secondname"
      SinatraApp.registrants[1][1].should == "secondemail@example.com"
    end

    it "redirects to a 'success' page after registration" do
      register_user "valid", "valid@example.com"

      page.should have_content "Registration successful!"
    end

    it "accepts names with letters or numbers" do
      assert_valid_names "hey", "ABC", "123"
    end

    it "allows valid emails" do
      assert_valid_email "valid@example.com"
    end
  end

  describe "unsuccessful registration" do
    it "doesn't accept non-alphanumeric characters" do
      assert_invalid_characters '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '[', ']', '{', '}', '\\', '|', ';', ':', "'", '"', ',', '.', '<', '>', '?', '/', '`', '~', '-', '_', '=', '+', 'å', '∫', '∑'
    end

    it "doesn't allow a blank name" do
      register_user "", "valid@example.com"
      SinatraApp.registrants.length.should be 0
    end

    it "limits names to 40 characters" do
      long_name = "a" * 50
      register_user long_name, "valid@example.com"
      SinatraApp.registrants.length.should be 0
    end

    it "only allows unique usernames" do
      register_user "valid", "valid@example.com"
      SinatraApp.registrants.length.should be 1
      register_user "valid", "differentvalid@example.com"
      SinatraApp.registrants.length.should be 1
    end

    it "doesn't allow invalid emails" do
      assert_invalid_emails "user@foo,com", "user_at_foo.org", "example.user@foo.", "foo@bar_baz.com", "foo@bar+baz.com"
    end

    it "only allows unique emails" do
      register_user "valid", "valid@example.com"
      SinatraApp.registrants.length.should be 1
      register_user "differentvalid", "valid@example.com"
      SinatraApp.registrants.length.should be 1
    end

    it "shows an appropriate flash message for invalid names" do
      assert_name_flash_message "invalid!", "Username must contain only alphanumeric characters"
      long_name = 'a' * 50
      assert_name_flash_message long_name, "Username must be less than 40 characters"

      register_user "taken", "differentvalid@example.com"
      assert_name_flash_message "taken", "Username is already taken"
    end

    it "shows an appropriate flash message for invalid emails" do
      register_user "valid", "@@invalid@@,,,,@,@,"
      page.should have_content( "Invalid email." )

      register_user "valid", "taken@example.com"
      register_user "differentvalid", "taken@example.com"
      page.should have_content( "Email already taken" )
    end
  end

  def assert_name_flash_message( name, flash_message )
    register_user name, "valid@example.com"
    page.should have_content( flash_message )
  end

  def assert_invalid_emails( *emails )
    emails.each do |email|
      register_user "valid", email
      SinatraApp.registrants.length.should be 0
    end
  end

  def assert_valid_email( email )
    register_user "valid", email
    SinatraApp.registrants.length.should be 1
  end

  def assert_valid_names( *names )
    names.each do |name, counter|
      expect{ register_user name, "valid#{name}@example.com" }.to change{ SinatraApp.registrants.length }.by 1
    end
  end

  def assert_invalid_characters( *characters )
    characters.each do |character|
      name = "invalid" << character
      register_user name, "valid@example.com"
      SinatraApp.registrants.length.should be 0
    end
  end

  def register_user( name, email )
    visit '/register'
    fill_in 'username', with: name
    fill_in 'email',    with: email
    click_button 'Submit'
  end
end
