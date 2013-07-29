class Spotilist < Sinatra::Base

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

  get uri_for(:playlist) do |playlist|
    @playlist = Hallon::Playlist.new(playlist).load
    @tracks = @playlist.tracks.to_a.map(&:load)
    @length = @tracks.inject(0) { |result, item| result + item.duration }

    haml :playlist
  end
end
