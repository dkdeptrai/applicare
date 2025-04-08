class Availability < ApplicationRecord
  belongs_to :repairer

  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :day_of_week, presence: true, inclusion: { in: 0..6 }
  validate :end_time_after_start_time
  validate :no_overlapping_availabilities

  private

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?
    errors.add(:end_time, "must be after start time") if end_time <= start_time
  end

  def no_overlapping_availabilities
    return if repairer.nil? || start_time.blank? || end_time.blank?

    overlapping = repairer.availabilities
      .where(day_of_week: day_of_week)
      .where.not(id: id)
      .where("(start_time < ? AND end_time > ?) OR (start_time < ? AND end_time > ?) OR (start_time >= ? AND end_time <= ?)",
             end_time, start_time, end_time, start_time, start_time, end_time)

    errors.add(:base, "overlaps with existing availability") if overlapping.exists?
  end
end
