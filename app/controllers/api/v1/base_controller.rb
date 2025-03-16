module Api
  module V1
    class BaseController < ActionController::API
      include JwtAuthenticable
      # Common API functionality can go here
    end
  end
end
