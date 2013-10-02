class Spotilist < Sinatra::Base
  not_found { haml :'404'}

  error Hallon::TimeoutError do
    status 504
    body "Hallon timed out."
  end

  error do
    Rollbar.report_exception(env['sinatra.error'])
    "error"
  end

  get '/' do
    haml :index
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
end
