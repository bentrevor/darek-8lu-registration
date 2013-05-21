require 'sinatra'
require 'openssl'

class SinatraApp < Sinatra::Base
  set :registrants, Hash.new

  get '/' do
    redirect :register
  end

  post '/validate_registration' do
    if invalid_username?
      @flash_message = invalid_username_flash_message
      erb :register
    elsif invalid_email?
      @flash_message = invalid_email_flash_message
      erb :register
    elsif registration_closed?
      @flash_message = "Registration is closed."
      erb :register
    else
      # send Darek two public/private pairs
      private_key = OpenSSL::PKey::RSA.new( 2048 )
      public_key = private_key.public_key
      keys = { public: public_key, private: private_key }
      user_hash = { email:      params[ :email ],
                    public_key: public_key,
                    private_key: private_key }

      settings.registrants[ params[ :username ].to_sym ] = user_hash

      private_key_file = "key_#{params[:username]}.pub"
      private_key_path =  File.join( 'public', 'keys', private_key_file )
      File.open( private_key_path, 'w' ) do |file|
        file.write private_key
        file.write "\n\n\n"
        file.write public_key
      end
      send_file private_key_path, { filename: private_key_file }
      redirect '/success'
    end
  end

  get '/success' do
    erb :registration_success
  end

  get '/download_key' do
    user_settings = settings.registrants[ session[ :username ]]
    key = user_settings[ :private_key ]
    # send back private key
    # send_file pub_file, { filename: pub_file }
    # different route for API private key download
  end

  get '/leaderboard' do
    erb :leaderboard
  end

  get '/register' do
    erb :register
  end

  private
  def invalid_username?
    name_regex_fails? or name_too_long? or name_not_unique?
  end

  def invalid_email?
    email_regex_fails? or email_not_unique?
  end

  def name_regex_fails?
    !( /^[a-zA-Z0-9]+$/ =~ params[:username] )
  end

  def email_regex_fails?
    !( /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i =~ params[:email] )
  end

  def name_not_unique?
    !( settings.registrants[ params[ :username ].to_sym ].nil? )
  end

  def email_not_unique?
    SinatraApp.registrants.each_value do |user|
      return true if user[ :email ] == params[ :email ]
    end

    false
  end

  def name_too_long?
    params[:username].length > 20
  end

  def invalid_username_flash_message
    if name_regex_fails?
      "Username must contain only alphanumeric characters."
    elsif name_too_long?
      "Username must be less than 20 characters."
    elsif name_not_unique?
      "Username is already taken."
    end
  end

  def invalid_email_flash_message
    if email_regex_fails?
      "Invalid email."
    elsif email_not_unique?
      "Email already taken."
    end
  end

  def registration_closed?
    settings.registrants.length >= 25
  end

  def self.clear_registrants
    settings.registrants = Hash.new
  end
end
