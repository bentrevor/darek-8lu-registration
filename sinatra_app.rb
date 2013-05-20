require 'sinatra'

class SinatraApp < Sinatra::Base
  set :registrations, []

  get '/' do
    redirect :register
  end

  post '/validate_registration' do
    if /^[a-z]*$/ =~ params[ :username ]
      settings.registrations << [ params[ :username ], params[ :email ] ]
      erb :registration_success
    end
  end

  get '/leaderboard' do
    erb :leaderboard
  end

  get '/register' do
    erb :register
  end
end
