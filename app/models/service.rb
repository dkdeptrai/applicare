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
