module JwtHelper
  def generate_repairer_jwt(repairer)
    payload = {
      repairer_id: repairer.id,
      exp: 24.hours.from_now.to_i
    }

    # Use JwtToken module from the application to ensure consistent encoding
    JwtToken.encode(payload)
  end
end

RSpec.configure do |config|
  config.include JwtHelper, type: :request
end
