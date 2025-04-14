module Api
  module V1
    class RepairerSessionsController < BaseController
      # Skip any potential user authentication from BaseController if it exists
      # Check if BaseController includes JwtAuthenticable
      if defined?(JwtAuthenticable) && self.ancestors.include?(JwtAuthenticable)
         skip_before_action :authenticate_request, only: [ :create ], raise: false
      end

      def create
        repairer = Repairer.find_by(email_address: params[:email_address]&.downcase)

        if repairer&.authenticate(params[:password])
          token = repairer.generate_jwt
          render json: { token: token, repairer: RepairerSerializer.new(repairer).as_json }, status: :created # Return token and basic repairer info
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      # Add a destroy action if you want repairers to be able to "log out" (invalidate tokens server-side is complex with JWT)
      # def destroy
      #   # Typically JWT logout is handled client-side by deleting the token
      #   head :no_content
      # end
    end
  end
end
