module Api
  module V1
    class MessagesController < BaseController
      skip_before_action :authenticate_request, only: []  # Require authentication for all actions
      before_action :set_booking
      before_action :authorize_booking_access

      def index
        @messages = @booking.messages.order(created_at: :asc)
        render json: @messages
      end

      def create
        @message = Message.new(message_params)
        @message.booking = @booking
        @message.sender = current_entity

        if @message.save
          render json: @message, status: :created
        else
          render json: { errors: @message.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_booking
        @booking = Booking.find(params[:booking_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Booking not found" }, status: :not_found
      end

      def authorize_booking_access
        # Check for current repairer specifically first to handle that case separately
        if current_repairer
          authorized = (@booking.repairer_id == current_repairer.id)
          unless authorized
            Rails.logger.info "Access denied: Repairer ID #{current_repairer.id} tried to access booking ID #{@booking.id} which belongs to repairer ID #{@booking.repairer_id}"
            render json: { error: "Unauthorized. This booking does not belong to you." }, status: :forbidden
            return
          end
          true # Allow access
        elsif current_user
          authorized = (@booking.user_id == current_user.id)
          unless authorized
            Rails.logger.info "Access denied: User ID #{current_user.id} tried to access booking ID #{@booking.id} which belongs to user ID #{@booking.user_id}"
            render json: { error: "Unauthorized. This booking does not belong to you." }, status: :forbidden
            return
          end
          true # Allow access
        else
          # No authenticated entity found
          Rails.logger.info "Access denied: No authenticated entity found"
          render json: { error: "Unauthorized. Authentication required." }, status: :forbidden
          false
        end
      end

      def message_params
        params.require(:message).permit(:content)
      end

      def current_entity
        current_user || current_repairer
      end
    end
  end
end
