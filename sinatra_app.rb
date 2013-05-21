require 'sinatra'
require 'openssl'
require 'json'

class SinatraApp < Sinatra::Base
  enable :sessions
  set :registrants, Hash.new
  @@registrants = settings.registrants

  get '/' do
    redirect :register
  end

  post '/validate_registration' do
    if invalid_username?
      show_menu_with invalid_username_flash_message
    elsif invalid_email?
      show_menu_with invalid_email_flash_message
    elsif registration_closed?
      show_menu_with "Registration is closed."
    else
      register_new_user
    end
  end

  get '/success' do
    erb :registration_success
  end

  get '/download_key' do
    send_file session[ :key_path ], { filename: 'private_key' }
  end

  get '/leaderboard' do
    erb :leaderboard
  end

  get '/register' do
    erb :register
  end

  get '/keys/*' do |username|
    if @@registrants[ username.to_sym ]
      erb :key_download
    else
      show_menu_with "You must register first."
    end
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
    !( @@registrants[ params[ :username ].to_sym ].nil? )
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
    @@registrants.length >= 25
  end

  def show_menu_with( message )
    @flash_message = message
    erb :register
  end

  def create_key_pair
    private_key = OpenSSL::PKey::RSA.new( 2048 )
    public_key = private_key.public_key
    return private_key, public_key
  end

  def register_new_user
    session[ :user ] = params[ :username ]

    private_key, public_key = create_key_pair

    hashed_email = Digest::MD5.hexdigest( params[ :email ].downcase )
    user_hash = { email:       params[ :email ],
                  email_md5:   hashed_email,
                  public_key:  public_key,
                  private_key: private_key }

    @@registrants[ params[ :username ].to_sym ] = user_hash

    private_key_file = "key_#{params[:username]}.pub"
    private_key_path =  File.join( 'public', 'keys', private_key_file )

    File.open( private_key_path, 'w' ) do |file|
      file.write private_key
    end

    session[ :key_path ] = private_key_path

    redirect '/success'
  end
end
