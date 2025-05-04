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
class AvailabilitySerializer < ActiveModel::Serializer
  attributes :id, :day_of_week, :start_time, :end_time, :created_at, :updated_at
  belongs_to :repairer
end
