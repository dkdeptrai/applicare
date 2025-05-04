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
class ServiceSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :duration_minutes, :base_price, :created_at, :updated_at
  belongs_to :repairer
end
