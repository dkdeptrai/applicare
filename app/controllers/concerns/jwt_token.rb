require "jwt"

module JwtToken
  extend ActiveSupport::Concern
  SECRET_KEY = Rails.application.credentials.jwt_secret.to_s

  def self.encode(payload, exp: 1.hour.from_now)
    payload[:exp] = exp.to_i
    payload[:iat] = Time.current.to_i # issued at claim

    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    return nil if token.nil?

    begin
      decoded = JWT.decode(token, SECRET_KEY, true, { verify_expiration: true })[0]
      HashWithIndifferentAccess.new decoded
    rescue JWT::ExpiredSignature
      # Re-raising to be caught by the authentication concern
      raise
    rescue JWT::DecodeError => e
      # Re-raising to be caught by the authentication concern
      raise
    end
  end
end
