class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :api_tokens, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Default email_verified to true
  after_create :auto_verify_email

  def generate_jwt
    JwtToken.encode({ user_id: id }, exp: 7.days.from_now)
  end

  def generate_email_verification_token
    update(
      email_verification_token: SecureRandom.urlsafe_base64,
      email_verification_sent_at: Time.current
    )
    email_verification_token
  end

  def verify_email!
    update(email_verified: true, email_verification_token: nil)
  end

  def email_verification_expired?
    email_verification_sent_at < 24.hours.ago if email_verification_sent_at
  end

  def send_verification_email
    # Email verification disabled for now
    # generate_email_verification_token
    # VerificationMailer.verification_email(self).deliver_later
    true
  end

  private

  def auto_verify_email
    update_column(:email_verified, true)
  end
end
