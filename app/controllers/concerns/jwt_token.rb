require "jwt"

module JwtToken
  extend ActiveSupport::Concern
  SECRET_KEY = Rails.application.credentials.jwt_secret.to_s
  def self.encode(payload, exp: 7.days.from_now)
    payload[:exp] = exp.to_i

    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new decoded
  rescue JWT::DecodeError
    nil
  end
end
