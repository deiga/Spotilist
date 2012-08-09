# spotilist.rb

require 'bundler/setup'
require 'sinatra'
require 'base64'

def env(varname)
  ENV.fetch(varname) do
    raise ConfigurationError, "Missing ENV['#{varname}']."
  end
end

class Spotilist < Sinatra::Base

  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  class ConfigurationError < StandardError
  end

  configure do 
    $hallon ||= begin
      require 'hallon'
      appkey = Base64.decode64(env('SPOTIFY_APPKEY'))
      Hallon.load_timeout = 35
      Hallon::Session.initialize(appkey).tap do |hallon|
        hallon.login!(env('SPOTIFY_USRNM'), env('SPOTIFY_PWD'))
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