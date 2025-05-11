module Api
  module V1
    class RepairerSessionsController < BaseController
      # Skip any potential user authentication from BaseController if it exists
      # Check if BaseController includes JwtAuthenticable
      if defined?(JwtAuthenticable) && self.ancestors.include?(JwtAuthenticable)
         skip_before_action :authenticate_request, only: [ :create ], raise: false
      end

      def create
        repairer = ::Repairer.find_by(email_address: params[:email_address]&.downcase)

        if repairer&.authenticate(params[:password])
          token_response = repairer.generate_token_pair
          render json: token_response.merge(repairer: RepairerSerializer.new(repairer).as_json), status: :created
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      def destroy
        # Invalidate refresh tokens on logout
        if current_repairer
          current_repairer.refresh_tokens.active.update_all(used: true)
          render json: { message: "Successfully logged out" }
        else
          render json: { error: "Not authenticated" }, status: :unauthorized
        end
      end
    end
  end
end
