module Api
  module V1
    class SessionsController < BaseController
      skip_before_action :authenticate_request, only: [ :create ]

      def create
        normalized_email = params[:email_address].to_s.strip.downcase
        user = User.find_by(email_address: normalized_email)
        if user&.authenticate(params[:password])
          token_response = user.generate_token_pair
          render json: token_response.merge(user_id: user.id), status: :ok
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      def destroy
        # If you want to invalidate refresh tokens on logout
        if current_user
          current_user.refresh_tokens.active.update_all(used: true)
          render json: { message: "Successfully logged out" }
        else
          render json: { error: "Not authenticated" }, status: :unauthorized
        end
      end
    end
  end
end
