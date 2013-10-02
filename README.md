Spotilist <sub><sup>(0.5.5)</sup></sub>
=========
[![Code Climate](https://codeclimate.com/github/deiga/Spotilist.png)](https://codeclimate.com/github/deiga/Spotilist)

Web application to display Spotify contents based on URI's.

It uses [Hallon](https://github.com/Burgestrand/Hallon), [libspotify](http://developer.spotify.com/en/libspotify/overview/) (through Hallon)
and [Sinatra](http://www.sinatrarb.com/)

It allows you to browse objects pointed to by Spotify URIs. All pages have a "Go to" box that allows you to paste in a Spotify URI to
view details about it.

## How to get it running
You’ll need your Spotify Premium Account credentials and a [Spotify Application Key](https://developer.spotify.com/technologies/libspotify/keys/).
Now, put all your credentials in your environment variables:

    export SPOTIFY_USRNM='your_username'
    export SPOTIFY_PWD='your_password'

Your application key needs special consideration, since it may contain special characters. It needs to
be encoded into base64 before putting it in the environment variable. Luckily, there is a ruby script
in `bin/serialize_appkey.rb` that will do this for you.

    export SPOTIFY_APPKEY="$(ruby bin/serialize_appkey.rb /path/to/appkey.rb)"

After this, you’ll want to download the dependencies:

- Ruby 1.9.2+
- [Bundler](http://gembundler.com/)

Finally, install all gems required for your platform by using bundler.

    bundle install

Now, you should have all dependencies.

## Running it locally

    bundle exec rackup

Done. Open it in your browser on `http://localhost:9292`.
