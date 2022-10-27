# file: app.rb
require 'sinatra'
require "sinatra/reloader"
require_relative 'lib/database_connection'
require_relative 'lib/album_repository'
require_relative 'lib/artist_repository'

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/album_repository'
    also_reload 'lib/artist_repository'
  end

  get '/artists/new' do
    return erb(:new_artist)
  end

  get '/albums/new' do
    return erb(:new_album)
  end

    get '/albums/:id' do
    repo = AlbumRepository.new
    repo2 = ArtistRepository.new
    @album = repo.find(params[:id])
    @artist = repo2.find(@album.artist_id)

    return erb(:albums)
end
  get '/albums' do
    repo = AlbumRepository.new
    @albums = repo.all

    return erb(:all_albums)
end

  post '/albums' do
    @title = params[:title]
    release_year = params[:release_year]
    artist_id = params[:artist_id]

    repo = AlbumRepository.new

    new_album = Album.new
    new_album.title = @title
    new_album.release_year = release_year
    new_album.artist_id = artist_id
    repo.create(new_album)

    return erb(:album_created)
end

get '/artists/:id' do
  repo = ArtistRepository.new
  @artist = repo.find(params[:id])
  return erb(:artists)
end

get '/artists' do
  repo = ArtistRepository.new
  @artists = repo.all
  return erb(:all_artists)
end

post '/artists' do
  @name = params[:name]
  genre = params[:genre]

  repo = ArtistRepository.new

  new_artist = Artist.new
  new_artist.name = @name
  new_artist.genre = genre
  repo.create(new_artist)
  
  return erb(:artist_created)
end

end