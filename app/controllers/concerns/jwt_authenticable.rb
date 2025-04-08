module JwtAuthenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
  end

  private

  def authenticate_request
    token = request.headers["Authorization"]&.split(" ")&.last

    if token.present?
      decoded_token = JwtToken.decode(token)
      if decoded_token.present? && decoded_token[:user_id].present?
        @current_user = User.find_by(id: decoded_token[:user_id])
        return if @current_user
      end
      render json: { error: "Unauthorized" }, status: :unauthorized
    else
      render json: { error: "Token not provided" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
