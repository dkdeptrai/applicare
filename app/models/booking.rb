class Booking < ApplicationRecord
  belongs_to :repairer
  belongs_to :user
  belongs_to :service

  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending confirmed cancelled completed] }
  validates :address, presence: true
  validate :time_slot_available
  validate :end_time_after_start_time
  validate :service_duration_matches_booking_duration

  before_validation :set_end_time_based_on_service

  private

  def set_end_time_based_on_service
    return if start_time.blank? || service.blank?
    self.end_time = start_time + service.duration_minutes.minutes
  end

  def time_slot_available
    return if repairer.nil? || start_time.blank? || end_time.blank?

    # Check if the time slot is within repairer's availability
    day_of_week = start_time.wday
    availability = repairer.availabilities.find_by(day_of_week: day_of_week)

    unless availability &&
           start_time.seconds_since_midnight >= availability.start_time.seconds_since_midnight &&
           end_time.seconds_since_midnight <= availability.end_time.seconds_since_midnight
      errors.add(:base, "time slot is not within repairer's availability")
    end

    # Check for overlapping bookings
    overlapping = repairer.bookings
      .where.not(id: id)
      .where.not(status: "cancelled")
      .where("(start_time < ? AND end_time > ?) OR (start_time < ? AND end_time > ?) OR (start_time >= ? AND end_time <= ?)",
             end_time, start_time, end_time, start_time, start_time, end_time)

    errors.add(:base, "time slot is already booked") if overlapping.exists?
  end

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?
    errors.add(:end_time, "must be after start time") if end_time <= start_time
  end

  def service_duration_matches_booking_duration
    return if start_time.blank? || end_time.blank? || service.blank?
    expected_duration = service.duration_minutes.minutes
    actual_duration = end_time - start_time
    unless (expected_duration - actual_duration).abs < 1.minute
      errors.add(:base, "booking duration must match service duration")
    end
  end
end
