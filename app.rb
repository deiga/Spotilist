# app.rb

require 'bundler/setup'
require 'sinatra'
require 'base64'
require 'hallon'
require_relative 'helpers/init'
require_relative 'routes/init'

class Spotilist < Sinatra::Base

  before do
    headers "Content-Type" => "text/html; charset=utf-8"
  end

  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
    enable :logging, :dump_errors, :raise_errors
  end

  configure do
    set :app_file, __FILE__

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

  configure :production do
    set :raise_errors, false #false will show nicer error page
    set :show_exceptions, false #true will ignore raise_errors and display backtrace in browser
  end

  at_exit do
    if Hallon::Session.instance?
      hallon = Hallon::Session.instance
      hallon.logout!
    end
  end

end
