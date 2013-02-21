# spotilist.rb

require 'bundler/setup'
require 'sinatra'
require 'base64'

before do
  headers "Content-Type" => "text/html; charset=utf-8"
end

def env(varname)
  ENV.fetch(varname) do
    raise ConfigurationError, "Missing ENV['#{varname}']."
  end
end

def uri_for(type)
  lambda do |uri|
    uri = uri.sub(%r{\A/}, '')
    return unless Hallon::Link.valid?(uri)
    return unless Hallon::Link.new(uri).type == type
    Hallon::URI.match(uri)
  end.tap do |matcher|
    matcher.singleton_class.send(:alias_method, :match, :call)
  end
end

class Spotilist < Sinatra::Base

  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  # configure :production do
  #   require 'newrelic_rpm'
  # end

  class ConfigurationError < StandardError
  end

  configure do
    $hallon ||= begin
      require 'hallon'
      appkey = Base64.decode64(env('SPOTIFY_APPKEY'))
      Hallon.load_timeout = 45
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

    def cache_for(mins = 1)
      if settings.environment != :development
        response['Cache-Control'] = "public, max-age=#{60*mins}"
      end
    end

    def logged_in_text
      if hallon.logged_in?
        user = hallon.user.load
        "logged in as #{link_to user.name, user}"
      else
        "lot logged in"
      end
    end

    def link_to(text, object)
      link = object.to_link
      %Q{<a class="#{link.type}" href="/#{link.to_uri}">#{text}</a>}
    end

    def image_to(image_link)
      %Q{<img src="/#{image_link.to_str}" class="#{image_link.type}">}
    end


  end

  at_exit do
    if Hallon::Session.instance?
      hallon = Hallon::Session.instance
      hallon.logout!
    end
  end

  not_found { haml :'404'}

  error Hallon::TimeoutError do
    status 504
    body "Hallon timed out."
  end

  get '/' do

    haml :index
  end

  get uri_for(:playlist) do |playlist|
    @playlist = Hallon::Playlist.new(playlist).load
    @tracks = @playlist.tracks.to_a.map(&:load)
    @length = @tracks.inject(0) { |result, item| result + item.duration }

    haml :playlist
  end

  get '/redirect_to' do
    begin
      link = Hallon::Link.new(params[:spotify_uri])
      redirect to("/#{link.to_uri}"), :see_other
    rescue ArgumentError => e
      @error = e
      halt 400, haml(:'400')
    end
  end

  get uri_for(:profile) do |user|
    @user = Hallon::User.new(user).load
    @starred = @user.starred.load
    @starred_tracks = @starred.tracks[0, 20].map(&:load)
    haml :user
  end

  get uri_for(:track) do |track|
    @track  = Hallon::Track.new(track).load
    @artist = @track.artist.load
    @album  = @track.album.load
    @length = Time.at(@track.duration).gmtime.strftime("%M:%S")
    haml :track
  end

  get uri_for(:artist) do |artist|
    @artist    = Hallon::Artist.new(artist).load
    @browse    = @artist.browse.load
    @portraits = @browse.portrait_links.to_a
    @portrait  = @portraits.shift
    @tracks    = @browse.tracks[0, 20].map(&:load)
    @similar_artists = @browse.similar_artists.to_a
    @similar_artists.each(&:load)
    haml :artist
  end

  get uri_for(:album) do |album|
    @album  = Hallon::Album.new(album).load
    @browse = @album.browse.load
    @cover  = @album.cover_link
    @artist = @album.artist.load
    @tracks = @browse.tracks[0, 20].map(&:load)
    @review = @browse.review
    haml :album
  end

  get uri_for(:image) do |img|
    image = Hallon::Image.new(img).load
    headers "Content-Type" => "image/#{image.format}"
    image.data
  end
end
