#GET results from Google Places API

json.google do
  json.array! @google_places do |place|
    json.extract! place, :name, :address, :coordinates, :opening_hours, :type, :rating
  end
end

#GET results from database, if any

json.database do
  json.array! @places do |place|
    json.extract! place, :name, :is_payment_available, :is_booking_available, :coordinates, :picture_url
  end
end

