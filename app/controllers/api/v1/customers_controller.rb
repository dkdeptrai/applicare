module Api
  module V1
    class CustomersController < BaseController
      skip_before_action :authenticate_request, only: []  # Require authentication for all actions
      before_action :authorize_repairer, only: [ :index, :show ]

      # GET /api/v1/customers
      # Lists all customers for a repairer (users who have bookings with the repairer)
      def index
        @customers = User.joins(:bookings)
                         .where(bookings: { repairer_id: current_repairer.id })
                         .distinct
                         .order(:name)

        render json: @customers, each_serializer: UserSerializer
      end

      # GET /api/v1/customers/:id
      # Show a specific customer's information
      def show
        @customer = User.joins(:bookings)
                        .where(bookings: { repairer_id: current_repairer.id })
                        .where(id: params[:id])
                        .first

        if @customer
          render json: @customer, serializer: UserSerializer
        else
          render json: { error: "Customer not found or not associated with this repairer" }, status: :not_found
        end
      end

      # GET /api/v1/customers/:id/bookings
      # Show a specific customer's bookings with the current repairer
      def bookings
        @customer = User.find_by(id: params[:id])

        if @customer && authorized_to_view_customer?(@customer)
          @bookings = @customer.bookings.where(repairer_id: current_repairer.id)
          render json: @bookings
        else
          render json: { error: "Customer not found or not associated with this repairer" }, status: :not_found
        end
      end

      private

      def authorize_repairer
        unless current_repairer
          render json: { error: "Only repairers can access customer information" }, status: :forbidden
        end
      end

      def authorized_to_view_customer?(customer)
        customer.bookings.where(repairer_id: current_repairer.id).exists?
      end
    end
  end
end
