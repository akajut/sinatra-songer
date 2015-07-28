require 'sinatra/base'

class App < Sinatra::Base

  configure :development do
    set :bind, '0.0.0.0'
    set :port, 9393
  end

  set :name, "App"

  get '/' do
    "this is the app"
  end

  get '/hello' do
    "Hello, this is #{settings.name}"
  end
end

class Sub < App
  set :name, "Sub"

  get '/' do
    "This is the sub app"
  end
end

Sub.run!