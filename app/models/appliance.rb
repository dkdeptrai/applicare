class Appliance < ApplicationRecord
  has_many :services, dependent: :destroy
  has_many :bookings, through: :services

  validates :name, presence: true
  validates :brand, presence: true
  validates :model, presence: true
end
