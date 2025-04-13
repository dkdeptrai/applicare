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
    end
  end
end
