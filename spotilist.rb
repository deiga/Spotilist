# spotilist.rb

require 'bundler/setup'
require 'sinatra'

class Spotilist < Sinatra::Base
  configure :production do
    require './libspotify-heroku'
  end

  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  configure do 
    $hallon ||= begin
      require 'hallon'
      appkey = IO.read(ENV['SPOTIFY_APPKEY'])
      Hallon.load_timeout = 35
      Hallon::Session.initialize(appkey).tap do |hallon|
        hallon.login!(ENV['SPOTIFY_USRNM'], ENV['SPOTIFY_PWD'])
      end
    end

    set :hallon, $hallon

    # Allow iframing
    disable :protection
  end

  helpers do
    def hallon
      Hallon::Session.instance
    end
  end

  at_exit do
    if Hallon::Session.instance?
      hallon = Hallon::Session.instance
      hallon.logout!
    end
  end

  error Hallon::TimeoutError do
    status 504
    body "Hallon timed out."
  end

  get %r{/(?<uri>spotify.*)} do |uri|
    session = Hallon::Session.instance
    unless Hallon::Link.valid?(uri)
      "Given URI was not a valid spotify URI"
    end
    uri = uri
    playlist_link = Hallon::Link.new(uri)

    @playlist = Hallon::Playlist.new(playlist_link).load
    @tracks = @playlist.tracks

    haml :index
  end
end