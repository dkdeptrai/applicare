module JwtHelper
  def generate_repairer_jwt(repairer)
    payload = {
      repairer_id: repairer.id,
      exp: 24.hours.from_now.to_i
    }

    # For test environment, let's make sure we have access to JwtToken and the correct secret
    if defined?(JwtToken)
      JwtToken.encode(payload)
    else
      # Fallback for tests
      require 'jwt'
      secret = Rails.application.credentials.jwt_secret.presence || Rails.application.credentials.secret_key_base
      JWT.encode(payload, secret)
    end
  end

  def generate_user_jwt(user)
    payload = {
      user_id: user.id,
      exp: 24.hours.from_now.to_i
    }

    # For test environment, let's make sure we have access to JwtToken and the correct secret
    if defined?(JwtToken)
      JwtToken.encode(payload)
    else
      # Fallback for tests
      require 'jwt'
      secret = Rails.application.credentials.jwt_secret.presence || Rails.application.credentials.secret_key_base
      JWT.encode(payload, secret)
    end
  end
end

RSpec.configure do |config|
  config.include JwtHelper, type: :request
end
