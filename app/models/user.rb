class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :api_tokens, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :services, through: :bookings
  has_many :appliances, through: :services

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true

  def generate_jwt
    JwtToken.encode({ user_id: id }, exp: 7.days.from_now)
  end
end
