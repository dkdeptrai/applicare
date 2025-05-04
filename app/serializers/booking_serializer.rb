# == Schema Information
#
# Table name: bookings
#
#  id          :bigint           not null, primary key
#  address     :text
#  end_time    :datetime
#  notes       :text
#  start_time  :datetime
#  status      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  repairer_id :bigint           not null
#  service_id  :bigint           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_bookings_on_repairer_id  (repairer_id)
#  index_bookings_on_service_id   (service_id)
#  index_bookings_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (repairer_id => repairers.id)
#  fk_rails_...  (service_id => services.id)
#  fk_rails_...  (user_id => users.id)
#
class BookingSerializer < ActiveModel::Serializer
  attributes :id, :start_time, :end_time, :status, :address, :notes, :created_at, :updated_at, :repairer_id, :service_id
  belongs_to :repairer
  belongs_to :user
  belongs_to :service
end
