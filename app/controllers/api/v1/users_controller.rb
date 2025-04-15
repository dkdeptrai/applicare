module Api
  module V1
    class UsersController < BaseController
      skip_before_action :authenticate_request, only: [ :create ]

      # GET /api/v1/users/:id
      def show
        user = User.find(params[:id])
        render json: user, serializer: UserSerializer # Use UserSerializer
      rescue ActiveRecord::RecordNotFound
        render json: { error: "User not found" }, status: :not_found
      end

      def create
        user = User.new(user_params)

        if user.save
          render json: { message: "User created successfully. You can now log in." }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/users/:id
      def update
        user = User.find(params[:id])

        # Ensure users can only update their own profile
        unless user.id == @current_user.id
          return render json: { error: "Unauthorized to update this user" }, status: :forbidden
        end

        if user.update(user_update_params)
          # Check if this is an onboarding update
          if onboarding_complete?(user_update_params) && !user.onboarded
            user.update(onboarded: true)
          end

          render json: user, serializer: UserSerializer
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
      end

      def user_update_params
        params.require(:user).permit(:name, :address, :date_of_birth, :mobile_number, :latitude, :longitude)
      end

      def onboarding_complete?(params)
        params[:date_of_birth].present? && params[:mobile_number].present? && params[:address].present?
      end
    end
  end
end
