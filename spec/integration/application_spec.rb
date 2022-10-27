require "spec_helper"
require "rack/test"
require_relative '../../app'
require 'album_repository'
require 'artist_repository'

def reset_tables
  seed_sql1 = File.read('spec/seeds/albums_seeds.sql')
  seed_sql2 = File.read('spec/seeds/artists_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql1)
  connection.exec(seed_sql2)
end

describe Application do
  before(:each) do 
    reset_tables
  end
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  context "GET /albums" do
    it 'returns a list of album links' do
      response = get('/albums')
      expect(response.status).to eq(200)
      expect(response.body).to include('<h1> Albums </h1>')
      expect(response.body).to include('<a href="/albums/1">Title: Doolittle')

    end
  end

  context "GET /albums/:id" do
    it 'returns a an album with a specific id' do
      response = get('/albums/1')
      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Doolittle</h1>')
    end
  end

  context 'GET /artists' do
    it 'returns a list of artists' do
      response = get('/artists')
      # result = 'Pixies, ABBA, Taylor Swift, Nina Simone'
      expect(response.status).to eq 200
      # expect(response.body).to eq result
      expect(response.body).to include ('<h1>Artists</h1>')
      expect(response.body).to include ('<a href="/artists/1">Name: Pixies')

    end
  end

  context 'GET /artists/:id' do
    it 'returns the html with an artist' do
      response = get('/artists/1')
      expect(response.status).to eq 200
      expect(response.body).to include ('<h1>Pixies</h1>')
    end

    it 'returns the html with  artist with id 2' do
      response = get('/artists/2')
      expect(response.status).to eq 200
      expect(response.body).to include ('<h1>ABBA</h1>')
    end
  end

  context 'GET /albums/new' do
    it 'should return an html form to add an album' do
      response = get('/albums/new')
      expect(response.status).to eq 200
      expect(response.body).to include ('<form action="/albums" method="POST">')
    end
  end

  context "POST /albums" do
    it 'should create a new album and return confirmation' do
      response = post('/albums', title: "Voyage", release_year: 2022, artist_id: 2)
      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Voyage added to albums!</h1>')
      response = get('/albums')
      expect(response.body).to include('Title: Voyage')
    end

    it 'should create a new album and return confirmation with another album' do
      response = post('/albums', title: "Wonderwall", release_year: 2022, artist_id: 5)
      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Wonderwall added to albums!</h1>')
      response = get('/albums')
      expect(response.body).to include('Title: Wonderwall')
    end
  end

  context 'GET /artists/new' do
    it 'should return an html form to add an artist' do
      response = get('/artists/new')
      expect(response.status).to eq 200
      expect(response.body).to include ('<form action="/artists" method="POST">')
    end
  end

  context "POST /artists" do
    it 'should create a new artist and return confirmation' do
      response = post('/artists', name: "Dermot Kennedy", genre: 'Pop')
      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Dermot Kennedy added to artists!</h1>')
      response = get('/artists')
      expect(response.body).to include('Name: Dermot Kennedy')
    end

    it 'should create a new album and return confirmation with another album' do
      response = post('/albums', title: "Wonderwall", release_year: 2022, artist_id: 5)
      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Wonderwall added to albums!</h1>')
      response = get('/albums')
      expect(response.body).to include('Title: Wonderwall')
    end
  end

end
