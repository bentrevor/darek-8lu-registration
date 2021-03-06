require_relative '../sinatra_app'
require 'fileutils'
require 'pp'
require 'capybara/rspec'

Capybara.app = SinatraApp

describe SinatraApp, type: :feature do
  let(:app) { SinatraApp }

  after :each do
    app.registrants.clear
  end

  after :all do
    FileUtils.rm_rf( Dir.pwd + "/public/keys" )
    FileUtils.mkdir( Dir.pwd + "/public/keys" )
    FileUtils.touch( Dir.pwd + "/public/keys/placeholder" )
  end

  describe "successful registration" do
    it "can register a user" do
      app.registrants.length.should be 0
      register_user "valid", "valid@example.com"

      app.registrants.length.should be 1
    end

    it "adds a user to a registrant hash" do
      register_user "firstname", "firstemail@example.com"
      register_user "secondname", "secondemail@example.com"

      app.registrants[ :firstname ].should_not be_nil
      app.registrants[ :secondname ].should_not be_nil
    end

    it "adds a hashed email to the registrant hash (for gravatars)" do
      register_user "ben", "BeNjaMin.trevor@gmail.com"

      app.registrants[ :ben ][ :email_md5 ].should == "0fac516aac163057250b11cbe2c23540"
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

    it "stores a public key on the server when a user registers" do
      register_user "valid", "valid@example.com"
      app.registrants[ :valid ][ :public_key ].public?.should be true
      app.registrants[ :valid ][ :private_key ].private?.should be true
    end

    it "redirects the user to a success page with private key download" do
      register_user "valid", "valid@example.com"
      page.should have_link( "private key", { href: "/download_key" })
    end
  end

  describe "unsuccessful registration" do
    it "doesn't accept non-alphanumeric characters" do
      assert_invalid_characters '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '[', ']', '{', '}', '\\', '|', ';', ':', "'", '"', ',', '.', '<', '>', '?', '/', '`', '~', '-', '_', '=', '+', 'å', '∫', '∑'
    end

    it "doesn't allow a blank name" do
      register_user "", "valid@example.com"
      app.registrants.length.should be 0
    end

    it "limits names to 20 characters" do
      long_name = "a" * 21
      register_user long_name, "valid@example.com"
      app.registrants.length.should be 0
    end

    it "only allows unique usernames" do
      register_user "valid", "valid@example.com"
      app.registrants.length.should be 1
      register_user "valid", "differentvalid@example.com"
      app.registrants.length.should be 1
      app.registrants[ :valid ][ :email ].should == "valid@example.com"
    end

    it "doesn't allow invalid emails" do
      assert_invalid_emails " white@space.com ", "user@foo,com", "user_at_foo.org", "example.user@foo.", "foo@bar_baz.com", "foo@bar+baz.com"
    end

    it "only allows unique emails" do
      register_user "valid", "valid@example.com"
      app.registrants.length.should be 1
      register_user "differentvalid", "valid@example.com"
      app.registrants.length.should be 1
      app.registrants[ :differentvalid ].should be_nil
    end

    it "shows an appropriate flash message for invalid names" do
      assert_name_flash_message "invalid!", "Username must contain only alphanumeric characters"
      long_name = 'a' * 50
      assert_name_flash_message long_name, "Username must be less than 20 characters"

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

    it "limits registrations to 25" do
      25.times do |counter|
        register_user "user#{counter}", "email#{counter}@example.com"
      end

      register_user "valid", "valid@example.com"
      page.should have_content( "Registration is closed." )
      app.registrants.length.should be 25
    end
  end

  describe "API" do
    it "provides a page for users to download their private key" do
      register_user "valid", "valid@example.com"

      visit '/keys/valid'
      page.should have_link( "private key", { href: "/download_key" })
    end

    it "turns away unregistered users" do
      visit '/keys/invalid'

      page.should have_content( "You must register first." )
      page.should_not have_link( "private key", { href: "/download_key" })
    end

    it "returns a json string of registered users" do
      register_user "valid1", "valid1@example.com"
      register_user "valid2", "valid2@example.com"
      register_user "valid3", "valid3@example.com"
      visit '/registered_users'

      json_response = JSON.parse( page.body )

      response_headers[ "Content-type" ].should =~ /application.json/
      json_response.length.should be 3
      json_response[0][ "valid1" ][ "email" ].should == "valid1@example.com"
      json_response[1][ "valid2" ][ "email" ].should == "valid2@example.com"
      json_response[2][ "valid3" ][ "email" ].should == "valid3@example.com"
    end
  end

  def assert_name_flash_message( name, flash_message )
    register_user name, "valid@example.com"
    page.should have_content( flash_message )
  end

  def assert_invalid_emails( *emails )
    emails.each do |email|
      register_user "valid", email
      app.registrants.length.should be 0
    end
  end

  def assert_valid_email( email )
    register_user "valid", email
    app.registrants.length.should be 1
  end

  def assert_valid_names( *names )
    names.each do |name, counter|
      expect{ register_user name, "valid#{name}@example.com" }.to change{ app.registrants.length }.by 1
    end
  end

  def assert_invalid_characters( *characters )
    characters.each do |character|
      name = "invalid" << character
      register_user name, "valid@example.com"
      app.registrants.length.should be 0
    end
  end

  def register_user( name, email )
    visit '/register'
    fill_in 'username', with: name
    fill_in 'email',    with: email
    click_button 'Submit'
  end
end
