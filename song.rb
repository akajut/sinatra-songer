require 'dm-core'
require 'dm-migrations'
require 'sinatra'
require 'slim'
require 'sass'
require 'sinatra/reloader' if development?
require 'sinatra/flash'

class Song
	include DataMapper::Resource
	property :id, Serial
	property :title, String
	property :lyrics, Text
	property :length, Integer
	property :released_on, Date
  property :likes, Integer, :default => 0

	def released_on=date
		super Date.strptime(date, '%m/%d/%Y')
	end
end

DataMapper.finalize

module SongHelpers
	def find_songs
		@songs = Song.all
	end

	def find_song
		Song.get(params[:id])
	end

	def create_song
		@song = Song.create(params[:song])
		#return Song.id
	end
end

helpers SongHelpers



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
	@title = "How to Contact Us || Songs by Sinatra"
	slim :contact
end

post '/songs' do
	protected!
	if create_song
		flash[:notice] = "Song successfully added"
	end
	redirect to("/songs/#{@song.id}")
end

get '/songs' do
	find_songs
	slim :songs
end

get '/songs/new' do
	protected!
	@song = Song.new
	slim :new_song
end

get '/songs/:id' do
	@title = "Sinatra Song:"
	@name = "Jut"
	@song = find_song
	slim :show_song
end

get '/songs/:id/edit' do
	protected!
	@song = find_song
	slim :edit_song
end

post '/songs/:id/like' do
	@song = find_song
  @song.likes = @song.likes.next
  @song.save
  redirect to"/songs/#{@song.id}" unless request.xhr?
  slim :like, :layout => false
end

put "/songs/:id" do
	protected!
	song = find_song
	if song.update(params[:song])
		flash[:notice] = "Song successfully updated"
	end
	redirect to("/songs/#{song.id}")
end

delete '/songs/:id' do
	protected!
	if find_song.destroy
		flash[:notice] = "Song deleted"
	end
	redirect to('/songs')
end

not_found do
	slim :not_found
end

__END__
@@show
<h1> Whudup <%= @name %>