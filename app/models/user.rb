# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  address         :string           default("")
#  date_of_birth   :date
#  email_address   :string           not null
#  latitude        :float
#  longitude       :float
#  mobile_number   :string
#  name            :string           not null
#  onboarded       :boolean          default(FALSE)
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :api_tokens, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :services, through: :bookings
  has_many :appliances, through: :services
  has_many :messages, as: :sender, dependent: :destroy
  has_many :refresh_tokens, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true

  def generate_jwt(exp = 1.hour.from_now)
    JwtToken.encode({ user_id: id }, exp: exp)
  end

  def generate_refresh_token
    RefreshToken.generate_for_user(self)
  end

  def generate_token_pair
    access_token = generate_jwt
    refresh_token = generate_refresh_token

    {
      access_token: access_token,
      refresh_token: refresh_token.token,
      expires_in: 3600, # 1 hour in seconds
      token_type: "Bearer"
    }
  end
end
