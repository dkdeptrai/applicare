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
        if decoded_token.present?
          if decoded_token[:user_id].present?
            @current_user = User.find_by(id: decoded_token[:user_id])
            return if @current_user
          elsif decoded_token[:repairer_id].present?
            @current_repairer = Repairer.find_by(id: decoded_token[:repairer_id])
            return if @current_repairer
          end
        end
        render json: { error: "Unauthorized" }, status: :unauthorized
      rescue JWT::ExpiredSignature
        render json: {
          error: "Unauthorized",
          code: "token_expired",
          message: "Your session has expired. Please refresh your token or login again."
        }, status: :unauthorized
      rescue JWT::DecodeError => e
        render json: {
          error: "Unauthorized",
          code: "invalid_token",
          message: "Authentication failed due to an invalid token."
        }, status: :unauthorized
      end
    else
      render json: { error: "Unauthorized", message: "Token not provided" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def current_repairer
    @current_repairer
  end
end
