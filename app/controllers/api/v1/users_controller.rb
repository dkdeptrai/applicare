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

      private

      def user_params
        params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
      end
    end
  end
end
