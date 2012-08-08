# spotilist.rb
class Spotilist < Sinatra::Base
	get '/' do
		"Hello World"
	configure :development do
		register Sinatra::Reloader
	end
	end
end