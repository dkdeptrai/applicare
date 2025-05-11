module Api
  module V1
    module Repairer
      class BookingsController < BaseController
        include JwtRepairerAuthenticable

        before_action :authenticate_repairer_request!
        before_action :set_booking, only: [ :show, :update, :notes ]

        # GET /api/v1/repairer/bookings
        # @swagger
        # /api/v1/repairer/bookings:
        #   get:
        #     summary: List all bookings for the authenticated repairer
        #     tags: [Repairer Bookings]
        #     security:
        #       - BearerAuth: []
        #     parameters:
        #       - in: query
        #         name: status
        #         schema:
        #           type: string
        #           enum: [pending, confirmed, completed, cancelled]
        #         description: Filter bookings by status
        #       - in: query
        #         name: start_date
        #         schema:
        #           type: string
        #           format: date
        #         description: Filter bookings from this date
        #       - in: query
        #         name: end_date
        #         schema:
        #           type: string
        #           format: date
        #         description: Filter bookings until this date
        #     responses:
        #       200:
        #         description: List of bookings
        #         content:
        #           application/json:
        #             schema:
        #               type: array
        #               items:
        #                 $ref: '#/components/schemas/Booking'
        #       401:
        #         description: Unauthorized
        def index
          @bookings = @current_repairer.bookings

          # Apply filters if provided
          @bookings = @bookings.where(status: params[:status]) if params[:status].present?
          @bookings = @bookings.where("start_time >= ?", params[:start_date]) if params[:start_date].present?
          @bookings = @bookings.where("start_time <= ?", params[:end_date]) if params[:end_date].present?

          render json: @bookings, each_serializer: BookingSerializer
        end

        # GET /api/v1/repairer/bookings/:id
        # @swagger
        # /api/v1/repairer/bookings/{id}:
        #   get:
        #     summary: Get booking details
        #     tags: [Repairer Bookings]
        #     security:
        #       - BearerAuth: []
        #     parameters:
        #       - in: path
        #         name: id
        #         required: true
        #         schema:
        #           type: integer
        #         description: Booking ID
        #     responses:
        #       200:
        #         description: Booking details
        #         content:
        #           application/json:
        #             schema:
        #               $ref: '#/components/schemas/Booking'
        #       401:
        #         description: Unauthorized
        #       404:
        #         description: Booking not found
        def show
          render json: @booking, serializer: BookingSerializer
        end

        # PATCH /api/v1/repairer/bookings/:id
        # @swagger
        # /api/v1/repairer/bookings/{id}:
        #   patch:
        #     summary: Update booking status
        #     tags: [Repairer Bookings]
        #     security:
        #       - BearerAuth: []
        #     parameters:
        #       - in: path
        #         name: id
        #         required: true
        #         schema:
        #           type: integer
        #         description: Booking ID
        #     requestBody:
        #       required: true
        #       content:
        #         application/json:
        #           schema:
        #             type: object
        #             properties:
        #               status:
        #                 type: string
        #                 enum: [confirmed, completed, cancelled]
        #                 description: New booking status
        #     responses:
        #       200:
        #         description: Booking updated successfully
        #         content:
        #           application/json:
        #             schema:
        #               $ref: '#/components/schemas/Booking'
        #       401:
        #         description: Unauthorized
        #       404:
        #         description: Booking not found
        #       422:
        #         description: Validation error
        def update
          if @booking.update(repairer_booking_params)
            render json: @booking, serializer: BookingSerializer
          else
            render json: { errors: @booking.errors.full_messages }, status: :unprocessable_entity
          end
        end

        # POST /api/v1/repairer/bookings/:id/notes
        # @swagger
        # /api/v1/repairer/bookings/{id}/notes:
        #   post:
        #     summary: Add a note to the booking
        #     tags: [Repairer Bookings]
        #     security:
        #       - BearerAuth: []
        #     parameters:
        #       - in: path
        #         name: id
        #         required: true
        #         schema:
        #           type: integer
        #         description: Booking ID
        #     requestBody:
        #       required: true
        #       content:
        #         application/json:
        #           schema:
        #             type: object
        #             properties:
        #               note:
        #                 type: string
        #                 description: Note content
        #     responses:
        #       200:
        #         description: Note added successfully
        #         content:
        #           application/json:
        #             schema:
        #               $ref: '#/components/schemas/Booking'
        #       401:
        #         description: Unauthorized
        #       404:
        #         description: Booking not found
        #       422:
        #         description: Validation error
        def notes
          if params[:note].blank?
            render json: { errors: [ "Note cannot be blank" ] }, status: :unprocessable_entity
            return
          end

          if @booking.update(repairer_note: params[:note])
            render json: @booking, serializer: BookingSerializer
          else
            render json: { errors: @booking.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def set_booking
          @booking = @current_repairer.bookings.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Booking not found" }, status: :not_found
        end

        def repairer_booking_params
          params.require(:booking).permit(:status)
        end
      end
    end
  end
end
