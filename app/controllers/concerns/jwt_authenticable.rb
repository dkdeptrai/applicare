module JwtAuthenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
  end

  private

  def authenticate_request
    token = request.header['Authorization']&.split(' ')&.last
    decoded_token = JwtToken.decode(token)

    if decoded_token
      @current_user = User.find(decoded_token[:user_id])
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
