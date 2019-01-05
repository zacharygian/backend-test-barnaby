class Api::V1::PlacesController < Api::V1::BaseController
  require 'json'
  require 'open-uri'
  require 'rest-client'

  # We open and parse the JSON extract file, in order to create a "fake DB"
  file = File.read("db/extract.json")
  data = JSON.parse(file)

  API_KEY = ENV['GOOGLE_API_KEY']
  AUTHORIZATION_TOKEN = ENV['AUTHORIZATION_TOKEN']
  # From that, we create a new hash for each bar in the DB with the following information
  PLACES = data["places"].map do |place|
    {
      id: place["id"],
      name: place["name"],
      is_payment_available: place["is_payment_available"],
      is_booking_available: place["is_booking_available"],
      coordinates: {
        latitude: place["coordinates"]["latitude"],
        longitude: place["coordinates"]["longitude"]
      },
      picture_url: place["picture_url"]
    }
  end

  # The API has a first endpoint or index at /places that fetches all the bars in the DB
  def index
    file = File.read "db/extract.json"
    data = JSON.parse(file)
    @places = PLACES
  end

  # Method that enables us to search for bars (or other establishments). It checks for authentication key and
  # search params. It first works with the "discover" keyword, or with a query string. The
  # method also handles error cases when there are no results, missing query, or invalid API key.
  # If the user does not specify a type, it will search for bars by default.
  def search
    if params[:key] == AUTHORIZATION_TOKEN && params[:q] == "discover"
      @google_places = discover
      @places = PLACES.select do |place|
        (place[:coordinates][:latitude].between?(average_location - 0.01, average_location + 0.01))
      end
    elsif params[:key] == AUTHORIZATION_TOKEN && params[:q]
      params_hash = {
        q: params[:q],
        type: params[:type] || "bar"
      }
      @google_places = call(params_hash)
      @places = PLACES.select do |place|
        (place[:name].downcase.include? (params[:q].downcase)) || (place[:coordinates][:latitude].between?(average_location - 0.01, average_location + 0.01))
      end

      render_error("empty") if @google_places.empty? && @places.empty?
    elsif params[:q]
      render_error
    else
      render_error("missing_params")
    end
  end

  # Method that allows the user to discover a new and random bar when using the "discover" keyword.
  def discover
    discover_places = [
      "Experimental Cocktail Club Paris",
      "Le Connetable",
      "Le Baron Rouge",
      "Le Bistrot des Dames",
      "Aux Folies",
      "UDO Bar"
    ]
    params_hash = {
      q: discover_places.sample
    }
    call(params_hash)
  end

  # Method that computes the Google Places API link, depending on the search params. This method is called by
  # the search method and the discover method, once the user has entered a query or keyword.
  def call(params_hash)
    url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=#{params_hash[:q]}&type=#{params_hash[:type]}&key=#{API_KEY}"
    fetch(url)
  end

  # This method fetches results from the Google Places API and computes a hash for each result
  # with the following information.
  def fetch(url)
    response = RestClient.get(url)
    data = JSON.parse(response)
    @google_results = data["results"].first(15).map do |result|
      {
        name: result["name"],
        address: result["formatted_address"],
        coordinates: {
          latitude: result["geometry"]["location"]["lat"],
          longitude: result["geometry"]["location"]["lng"]
        },
        opening_hours: result["opening_hours"],
        type: result["types"].first,
        rating: result["rating"]
      }
    end
    @google_results
  end

  # Method that computes the average location of the Google Places API results.
  # This is later used to return nearby bars from the existing DB bars.
  def average_location
    @lat_counter = 0
    @google_results.each do |bar|
      @lat_counter += bar[:coordinates][:latitude]
    end
    if @google_results.count > 0
      @avg_lat = @lat_counter / @google_results.count
    else
      @avg_lat = 0
    end
  end

  # Method that handles errors in different cases.
  def render_error(type = nil)
    if type == "empty"
      render json: { error: "No results were found! Please try again with another keyword." }, status: 422
    elsif type == "missing_params"
      render json: { error: "Query missing. Please try again with a query string." }
    else
      render json: { error: "Access denied: your API key is invalid. Please enter a valid API key to continue." }, status: 401
    end
  end
end

