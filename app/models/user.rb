class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy


  normalizes :email_address, with: ->(e) { e.strip.downcase }
  def generate_jwt
    JwtToken.encode user_id: id
  end
end
