class Spotilist < Sinatra::Base

  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
    enable :logging, :dump_errors, :raise_errors
  end

  configure :production do
    require 'newrelic_rpm'
  end

  configure do
    set :environment, ENV['RACK_ENV'].to_sym
    set :root, Dir.pwd
    set :app_file, Proc.new { File.join(root, "app.rb") }

    $hallon ||= begin
      require 'hallon'
      appkey = Base64.decode64(env('SPOTIFY_APPKEY'))
      if appkey.nil? or appkey.empty?
        raise "Could not find SPOTIFY_APPKEY in environment. Run `export SPOTIFY_APPKEY=\"$(ruby bin/serialize_appkey.rb /path/to/appkey.rb)\"`"
      end
      Hallon.load_timeout = 45
      Hallon::Session.initialize(appkey).tap do |hallon|
        hallon.login!(env('SPOTIFY_USRNM'), env('SPOTIFY_PWD'))
      end
    end

    set :hallon, $hallon

    # Allow iframing
    disable :protection
    # Only one request at a time
    enable :lock
  end

  configure :production do
    set :raise_errors, false #false will show nicer error page
    set :show_exceptions, false #true will ignore raise_errors and display backtrace in browser
  end
end
