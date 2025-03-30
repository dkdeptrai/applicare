module Api
  module V1
    class EmailVerificationsController < BaseController
      skip_before_action :authenticate_request, only: [ :verify, :resend ]

      def verify
        user = User.find_by(email_verification_token: params[:token])

        if user.present?
          if user.email_verification_expired?
            user.send_verification_email
            render json: { message: "Verification link expired. A new verification link has been sent to your email." }, status: :unprocessable_entity
          else
            user.verify_email!
            render json: { message: "Email verified successfully! You can now log in." }
          end
        else
          render json: { error: "Invalid verification link." }, status: :not_found
        end
      end

      def resend
        user = User.find_by(email_address: params[:email])

        if user.present? && !user.email_verified?
          user.send_verification_email
          render json: { message: "Verification email sent successfully. Please check your inbox." }
        else
          # Return success message even if user doesn't exist for security
          render json: { message: "If your account exists and is not verified, a verification email has been sent." }
        end
      end
    end
  end
end
