# == Schema Information
#
# Table name: appliances
#
#  id         :bigint           not null, primary key
#  brand      :string           not null
#  image_url  :string
#  model      :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Appliance < ApplicationRecord
  has_many :services, dependent: :destroy
  has_many :bookings, through: :services

  validates :name, presence: true
  validates :brand, presence: true
  validates :model, presence: true
end
