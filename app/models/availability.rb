# == Schema Information
#
# Table name: availabilities
#
#  id          :bigint           not null, primary key
#  day_of_week :integer
#  end_time    :time
#  start_time  :time
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  repairer_id :bigint           not null
#
# Indexes
#
#  index_availabilities_on_repairer_id  (repairer_id)
#
# Foreign Keys
#
#  fk_rails_...  (repairer_id => repairers.id)
#
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
