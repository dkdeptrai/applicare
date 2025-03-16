module JwtAuthenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
  end

  private

  def authenticate_request
    token = request.headers["Authorization"]&.split(" ")&.last

    if token.present?
      begin
        decoded_token = JwtToken.decode(token)
        @current_user = User.find(decoded_token[:user_id])
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    else
      render json: { error: "Token not provided" }, status: :unauthorized
    end
  end
end
