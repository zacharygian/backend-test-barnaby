class Api::V1::PlacesController < Api::V1::BaseController
  require 'json'
  require 'open-uri'
  require 'rest-client'

  file = File.read("db/extract.json")
  data = JSON.parse(file)

  API_KEY = ENV['GOOGLE_API_KEY']
  AUTHORIZATION_TOKEN = ENV['AUTHORIZATION_TOKEN']
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

  def index
    file = File.read "db/extract.json"
    data = JSON.parse(file)
    @places = PLACES
  end

  def search
    if params[:key] == AUTHORIZATION_TOKEN && params[:q] == "discover"
      @google_places = discover
      @places = PLACES.select do |place|
        (place[:coordinates][:latitude].between?(average_location - 0.01, average_location + 0.01))
      end
    elsif params[:key] == AUTHORIZATION_TOKEN && params[:q]
      params_hash = {
        q: params[:q],
        type: params[:type] || "bar",
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

  def discover
    discover_places = [
      "Experimental Cocktail Club Paris",
      "Le Connetable",
      "Le Baron Rouge",
      "Le Bistrot des Dames",
      "Aux Folies",
      "UDO Bar",
      "Le Motel"
    ]
    params_hash = {
      q: discover_places.sample
    }
    call(params_hash)
  end

  def call(params_hash)
    url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=#{params_hash[:q]}&type=#{params_hash[:type]}&key=#{API_KEY}"
    fetch(url)
  end

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

  def render_error(type = nil)
    if type == "empty"
      render json: { error: "No results were found! Please try again with another keyword." }
    elsif type == "missing_params"
      render json: { error: "Query missing. Please try again with a query string." }
    else
      render json: { error: "Access denied: your API key is invalid. Please enter a valid API key to continue." }
    end
  end
end

