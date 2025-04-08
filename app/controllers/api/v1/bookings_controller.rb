module Api
  module V1
    class BookingsController < BaseController
      before_action :set_booking, only: [ :show, :update, :destroy ]

      def index
        @bookings = current_user.bookings
        render json: @bookings, each_serializer: BookingSerializer
      end

      def create
        @booking = current_user.bookings.build(booking_params)
        @booking.status = "pending"

        if @booking.save
          render json: @booking, serializer: BookingSerializer, status: :created
        else
          render json: { errors: @booking.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def show
        render json: @booking, serializer: BookingSerializer
      end

      def update
        if @booking.update(booking_params)
          render json: @booking, serializer: BookingSerializer
        else
          render json: { errors: @booking.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @booking.update(status: "cancelled")
        head :no_content
      end

      private

      def set_booking
        @booking = current_user.bookings.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Booking not found" }, status: :not_found
      end

      def booking_params
        params.require(:booking).permit(
          :repairer_id,
          :service_id,
          :start_time,
          :address,
          :notes
        )
      end
    end
  end
end
