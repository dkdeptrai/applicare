class Repairer < ApplicationRecord
  geocoded_by :address # if you have an address field to geocode from
  # If you only store lat/lon and don't geocode from address, you might not need geocoded_by
  # but you DO need to specify the columns for reverse geocoding and distance calculations:
  reverse_geocoded_by :latitude, :longitude # Assuming you have these columns
  # after_validation :geocode # Omit if you manually set lat/lon

  has_many :services, dependent: :destroy
  has_many :availabilities, dependent: :destroy
  has_many :bookings, foreign_key: :repairer_id, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :appliances, through: :services

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :hourly_rate, presence: true, numericality: { greater_than: 0 }
  validates :service_radius, presence: true, numericality: { greater_than: 0 }

  has_secure_password

  def generate_jwt
    # Ensure JwtToken class/module is available (e.g., require 'jwt_token' if needed)
    JwtToken.encode({ repairer_id: id }, exp: 7.days.from_now)
  end

  def available_time_slots(date)
    day_of_week = date.wday
    availability = availabilities.find_by(day_of_week: day_of_week)
    return [] unless availability

    # Get all bookings for the date
    bookings_for_date = bookings.where(
      "DATE(start_time) = ? AND status != ?",
      date,
      "cancelled"
    )

    # Generate time slots based on availability
    slots = []
    current_time = availability.start_time
    while current_time < availability.end_time
      slot_end = current_time + 1.hour
      # Check if this slot is already booked
      is_booked = bookings_for_date.any? do |booking|
        booking_start = booking.start_time.seconds_since_midnight
        booking_end = booking.end_time.seconds_since_midnight
        slot_start = current_time.seconds_since_midnight
        slot_end_time = slot_end.seconds_since_midnight

        # Check for overlap
        (slot_start < booking_end && slot_end_time > booking_start)
      end

      slots << {
        start_time: current_time,
        end_time: slot_end,
        available: !is_booked
      }

      current_time = slot_end
    end

    slots
  end
end
