module Api
  module V1
    class TokenController < BaseController
      skip_before_action :authenticate_request, only: [ :refresh ]

      # POST /api/v1/token/refresh
      def refresh
        refresh_token = params[:refresh_token]

        unless refresh_token
          render json: { error: "Refresh token is required" }, status: :bad_request
          return
        end

        token_record = RefreshToken.find_by(token: refresh_token)

        unless token_record&.valid_for_refresh?
          render json: { error: "Invalid or expired refresh token" }, status: :unauthorized
          return
        end

        # Mark the old refresh token as used to prevent replay attacks
        token_record.mark_as_used!

        # Determine if this is a user or repairer
        owner = token_record.owner

        # Generate new token pair
        token_response = owner.generate_token_pair

        render json: token_response, status: :ok
      end
    end
  end
end
