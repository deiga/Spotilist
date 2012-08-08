# spotilist.rb
require 'hallon'

class Spotilist < Sinatra::Base
	configure :development do
		register Sinatra::Reloader
	end

	Hallon.load_timeout = 60.0

	get '/:uri' do
		if Hallon::Session.instance?
			session = Hallon::Session.instance
		else
			session = Hallon::Session.initialize IO.read('./spotify_appkey.key')
		end
		unless Hallon::Link.valid?(params[:uri])
			"Given URI was not a valid spotify URI"
		end
		session.login!(ENV['SPOTIFY_USRNM'], ENV['SPOTIFY_PWD'])
		uri = params[:uri]
		playlist_link = Hallon::Link.new(uri)
		
		@playlist = Hallon::Playlist.new(playlist_link).load
		@tracks = @playlist.tracks
		
		haml :index
	end
end