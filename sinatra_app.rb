require 'sinatra'

class SinatraApp < Sinatra::Base
  get '/' do
    erb :scoreboard
  end
end
