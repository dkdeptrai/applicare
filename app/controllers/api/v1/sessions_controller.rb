module Api
  module V1
    class SessionsController < BaseController
      skip_before_action :authenticate_request, only: [ :create ]

      def create
        user = User.find_by(email_address: params[:email])
        if user&.authenticate(params[:password])
          # Email verification disabled for now
          token = user.generate_jwt
          render json: { token: token, user_id: user.id }
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      def destroy
        # If using token revocation or blacklisting, implement here
        render json: { message: "Successfully logged out" }
      end
    end
  end
end
