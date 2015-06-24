require 'dm-core'
require 'dm-migrations'
require 'sinatra'
require 'slim'
require 'sass'

#set :port, 3000

class Song
	include DataMapper::Resource
	property :id, Serial
	property :title, String
	property :lyrics, Text
	property :length, Integer
	property :released_on, Date

	def released_on=date
		super Date.strptime(date, '%m/%d/%Y')
	end
end

DataMapper.finalize




get('/styles.css'){ scss :styles }

get '/' do
	@title = "Songs by Sinatra"
	slim :home
end

get '/about' do
	@title = "All About This Sinatra Website"
	slim :about
end

get '/contact' do
	@title = "How to Contact Us"
	slim :contact
end

post '/songs' do
	song = Song.create(params[:song])
	redirect to("/songs/#{song.id}")
end
get '/songs' do
	@songs = Song.all
	slim :songs
end

get '/songs/new' do
	halt(401, 'Not Autorized') unless session[:admin]
	@song = Song.new
	slim :new_song
end

get '/songs/:id' do
	@title = "Sinatra Song:"
	@name = "Jut"
	@song = Song.get(params[:id])
	slim :show_song
end

get '/songs/:id/edit' do
	halt(401, 'Not Autorized') unless session[:admin]
	@song = Song.get(params[:id])
	slim :edit_song
end

put "/songs/:id" do
	halt(401, 'Not Autorized') unless session[:admin]
	song = Song.get(params[:id])
	song.update(params[:song])
	redirect to("/songs/#{song.id}")
end

delete '/songs/:id' do
	halt(401, 'Not Autorized') unless session[:admin]
	Song.get(params[:id]).destroy
	redirect to('/songs')
end

not_found do
	slim :not_found
end

__END__
@@show
<h1> Whudup <%= @name %>