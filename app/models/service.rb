# == Schema Information
#
# Table name: services
#
#  id               :bigint           not null, primary key
#  base_price       :decimal(, )
#  description      :text
#  duration_minutes :integer
#  name             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  appliance_id     :bigint           not null
#  repairer_id      :bigint           not null
#
# Indexes
#
#  index_services_on_appliance_id  (appliance_id)
#  index_services_on_repairer_id   (repairer_id)
#
# Foreign Keys
#
#  fk_rails_...  (appliance_id => appliances.id)
#  fk_rails_...  (repairer_id => repairers.id)
#
class Service < ApplicationRecord
  belongs_to :repairer
  belongs_to :appliance
  has_many :bookings, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
  validates :duration_minutes, presence: true, numericality: { greater_than: 0 }
  validates :base_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :repairer, presence: true
  validates :appliance, presence: true

  def calculate_price
    # This is a simple calculation - you might want to add more complex pricing logic
    base_price
  end
end
