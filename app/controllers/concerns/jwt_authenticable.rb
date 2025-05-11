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
        Rails.logger.info "JWT decoded: #{decoded_token.inspect}"

        if decoded_token.present?
          if decoded_token[:user_id].present?
            @current_user = User.find_by(id: decoded_token[:user_id])
            Rails.logger.info "Found user: #{@current_user.inspect}" if @current_user
            return if @current_user
          elsif decoded_token[:repairer_id].present?
            @current_repairer = Repairer.find_by(id: decoded_token[:repairer_id])
            Rails.logger.info "Found repairer: #{@current_repairer.id}" if @current_repairer
            return if @current_repairer
          end
        end

        Rails.logger.warn "JWT authentication failed: Token decoded but no valid user/repairer found"
        render json: { error: "Unauthorized" }, status: :unauthorized
      rescue JWT::ExpiredSignature
        Rails.logger.warn "JWT authentication failed: Token expired"
        render json: {
          error: "Unauthorized",
          code: "token_expired",
          message: "Your session has expired. Please refresh your token or login again."
        }, status: :unauthorized
      rescue JWT::DecodeError => e
        Rails.logger.warn "JWT authentication failed: #{e.message}"
        render json: {
          error: "Unauthorized",
          code: "invalid_token",
          message: "Authentication failed due to an invalid token."
        }, status: :unauthorized
      end
    else
      Rails.logger.warn "JWT authentication failed: No token provided"
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
