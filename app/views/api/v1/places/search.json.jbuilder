#GET request: results from Google Places API and database at /places/search?q=?...

json.google do
  json.array! @google_places do |place|
    json.extract! place, :name, :address, :coordinates, :opening_hours, :type, :rating
  end
end

json.database do
  json.array! @places do |place|
    json.extract! place, :name, :is_payment_available, :is_booking_available, :coordinates, :picture_url
  end
end

