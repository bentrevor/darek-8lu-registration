require 'sinatra'

class SinatraApp < Sinatra::Base
  set :registrations, []

  post '/register' do
    settings.registrations << [ params[ :username ], params[ :email ] ]
  end

  get '/leaderboard' do
    erb :leaderboard
  end

  get '/register' do
    erb :register
  end
end
