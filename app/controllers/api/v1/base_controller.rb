module Api
  module V1
    class BaseController < ActionController
      include JwtAuthenticable
      protect_from_forgery with: :null_session
      # Common API functionality can go here
    end
  end
end
