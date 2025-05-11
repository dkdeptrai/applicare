require "jwt"

# Configure JWT for the application
# You can add custom JWT claims here if needed in the future

# Define JWT::ExpiredSignature if it doesn't already exist
unless defined?(JWT::ExpiredSignature)
  module JWT
    class ExpiredSignature < JWT::DecodeError; end
  end
end

# Use this to verify JWT secret is set
if Rails.application.credentials.jwt_secret.blank? && Rails.env.production?
  Rails.logger.warn "WARNING: JWT secret is not set in credentials. Authentication will not work correctly."
end
