module JwtRepairerAuthenticable
  extend ActiveSupport::Concern

  private

  # This method is intended to be called explicitly via before_action
  # e.g., before_action :authenticate_repairer_request!
  def authenticate_repairer_request!
    token = request.headers["Authorization"]&.split(" ")&.last

    unless token
      render json: { error: "Token not provided" }, status: :unauthorized
      return false
    end

    begin
      decoded_token = JwtToken.decode(token)
      unless decoded_token && decoded_token[:repairer_id]
        render json: { error: "Invalid token format or missing repairer_id" }, status: :unauthorized
        return false
      end

      @current_repairer = Repairer.find_by(id: decoded_token[:repairer_id])
      unless @current_repairer
        render json: { error: "Unauthorized - Repairer not found" }, status: :unauthorized
        return false
      end

      true # Indicate successful authentication
    rescue JWT::ExpiredSignature
      render json: {
        error: "Token expired",
        code: "token_expired",
        message: "Your session has expired. Please refresh your token or login again."
      }, status: :unauthorized
      false
    rescue JWT::DecodeError => e
      render json: {
        error: "Invalid token",
        code: "invalid_token",
        message: "Authentication failed due to an invalid token."
      }, status: :unauthorized
      false
    end
  end

  def current_repairer
    @current_repairer
  end
end
