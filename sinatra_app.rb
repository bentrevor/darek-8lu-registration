require 'sinatra'

class SinatraApp < Sinatra::Base
  set :registrants, []

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
    else
      settings.registrants << [ params[:username], params[:email] ]
      redirect '/success'
    end
  end

  get '/success' do
    erb :registration_success
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
    settings.registrants.each do |registrant|
      return true if registrant[0] == params[:username]
    end

    false
  end

  def email_not_unique?
    settings.registrants.each do |registrant|
      return true if registrant[1].downcase == params[:email].downcase
    end

    false
  end

  def name_too_long?
    params[:username].length > 40
  end

  def invalid_username_flash_message
    if name_regex_fails?
      "Username must contain only alphanumeric characters."
    elsif name_too_long?
      "Username must be less than 40 characters."
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
end
