module Api
  module V1
    class ProfilesController < BaseController
      # GET /api/v1/profile
      def show
        # Relies on @current_user set by authenticate_request in BaseController
        if @current_user
          render json: @current_user, serializer: UserSerializer
        else
          # Should ideally not be reached if authenticate_request runs
          render json: { error: "Not authenticated" }, status: :unauthorized
        end
      end

      # PUT/PATCH /api/v1/profile
      def update
        if @current_user.update(profile_params)
          # Check if this is an onboarding update
          if onboarding_complete?(profile_params) && !@current_user.onboarded
            @current_user.update(onboarded: true)
          end

          render json: @current_user, serializer: UserSerializer
        else
          render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def profile_params
        params.require(:user).permit(:name, :address, :date_of_birth, :mobile_number, :latitude, :longitude)
      end

      def onboarding_complete?(params)
        params[:date_of_birth].present? && params[:mobile_number].present? && params[:address].present?
      end
    end
  end
end
