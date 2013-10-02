# app.rb

require 'bundler/setup'
require 'sinatra'
require 'base64'
require 'hallon'
require_relative 'helpers/init'
require_relative 'routes/init'
require_relative 'config/init'

class Spotilist < Sinatra::Base

  at_exit do
    if Hallon::Session.instance?
      hallon = Hallon::Session.instance
      hallon.logout!
    end
  end

  before do
    headers "Content-Type" => "text/html; charset=utf-8"
    unless hallon.logged_in?
      hallon.login!(config_env('SPOTIFY_USRNM'), config_env('SPOTIFY_PWD'))
    end
  end

end
