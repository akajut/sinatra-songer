require './song'
require 'pony'
require './sinatra/auth'

require 'v8'
require 'coffee-script'


configure do
	enable :sessions
	set :username, 'frank'
	set :password, 'sinatra'
end

configure :development do
	DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")

  set :bind, '0.0.0.0'
  #set :port, 9393
  
	set :email_address => 'smtp.gmail.com',
		:email_user_name => 'akajut',
		:email_password => 'secret',
		:email_domain => 'localhost.localdomain'
end

configure :production do
	DataMapper.setup(:default, ENV['DATABASE_URL'])

	set :email_address => 'smtp.sendgrid.net',
		:email_user_name => ENV['SENDGRID_USERNAME'],
		:email_password => ENV['SENDGRID_PASSWORD'],
		:email_domain => 'heroku.com'
end

before do
	set_title
end

helpers do
	def css(*stylesheets)
		stylesheets.map do |styleheet|
			"<link href=\"/#{styleheet}.css\" media=\"screen, projection\" rel=\"stylesheet\" />"
		end.join
	end

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
end

get('/styles.css'){ scss :styles }
get('/javascripts/application.js'){ coffee :application }



get '/login' do
	slim :login
end

post '/login' do
	if params[:username] == settings.username && params[:password] == settings.password
		session[:admin] = true
		redirect to ('/songs')
	else
		slim :login
	end
end

get '/logout' do
	session.clear
	redirect to ('login')
end

get '/set/:name' do
	session[:name] = params[:name]
end

get '/get/hello' do
	"Hello #{session[:name]}"
end

post '/contact' do
	send_message
	flash[:notice] = "Thank your for your message. We'll be in touch soon."
	redirect to('/')
end