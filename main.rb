require 'sinatra/base'
require 'slim'
require 'sass'
require 'sinatra/flash'
require 'pony'
require './sinatra/auth'
require 'v8'
require 'coffee-script'
require_relative 'asset-handler'
require 'sinatra/reloader'

class Website < Sinatra::Base
  use AssetHandler
  register Sinatra::Auth
  register Sinatra::Flash
  register Sinatra::Reloader

configure do
	enable :sessions
	set :username, 'frank'
	set :password, 'sinatra'
end

configure :development do

  set :bind, '0.0.0.0'
  set :port, 9393

	set :email_address => 'smtp.gmail.com',
		:email_user_name => 'akajut',
		:email_password => 'secret',
		:email_domain => 'localhost.localdomain'
end

configure :production do
	set :email_address => 'smtp.sendgrid.net',
		:email_user_name => ENV['SENDGRID_USERNAME'],
		:email_password => ENV['SENDGRID_PASSWORD'],
		:email_domain => 'heroku.com'
end

before do
	set_title
end

  #looping stlesheets called in templates...
def css(*stylesheets)
	stylesheets.map do |styleheet|
		"<link href=\"/#{styleheet}.css\" media=\"screen, projection\" rel=\"stylesheet\" />"
	end.join
end

#adding optional trailing slash for nav highlighting with current class...
def current?(path='/')
	(request.path==path || request.path==path+'/') ? "current" :nil
end

def set_title
	@title ||= "Songs By Sinatra"
end

def send_message
	Pony.mail(
			:from => params[:name] + "<" + params[:email] + ">",
			:to => 'akajut@gmail.com',
			:subject => params[:name] = " has contacted you",
			:body => params[:message],
			:port => '587',
			:via => :smtp,
			:via_options => {
				:address				=> 'smtp.gmail.com',
				:port					=> '587',
				:enable_starttls_auto 	=> true,
				:user_name				=> 'akajut',
				:password				=> 'secret',
				:authentication			=> :plain,
				:domain					=> 'localhost.localdomain'
			}
		)
end





get '/' do
	slim :home
end

get '/about' do
	@title = "All About This Sinatra Website"
	slim :about
end

get '/contact' do
	@title = "How to Contact Us || Songs by Sinatra"
	slim :contact
end

not_found do
  slim :not_found
end

post '/contact' do
	send_message
	flash[:notice] = "Thank your for your message. We'll be in touch soon."
	redirect to('/')
end

end