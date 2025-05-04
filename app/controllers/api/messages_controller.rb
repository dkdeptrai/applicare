module Api
  class MessagesController < ActionController::API
    include ApiAuthentication

    before_action :authenticate_entity
    before_action :set_booking
    before_action :authorize_booking_access

    def index
      @messages = @booking.messages.order(created_at: :asc)
      render json: @messages
    end

    def create
      @message = current_entity.messages.new(message_params)
      @message.booking = @booking

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
      authorized = if current_entity.is_a?(User)
                    @booking.user_id == current_entity.id
      elsif current_entity.is_a?(Repairer)
                    @booking.repairer_id == current_entity.id
      else
                    false
      end

      render json: { error: "Unauthorized" }, status: :forbidden unless authorized
    end

    def message_params
      params.require(:message).permit(:content)
    end
  end
end
