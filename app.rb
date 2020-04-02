require 'sinatra/base'

class AdjustedGithubApp < Sinatra::Application
  get '/' do
    erb :index
  end
end
