json.database do
  json.array! @places do |place|
    json.extract! place, :name, :is_payment_available, :is_booking_available, :coordinates, :picture_url
  end
end
