module Api
  module V1
    class RepairersController < BaseController
      before_action :set_repairer, only: [ :show, :destroy, :availability, :calendar ]

      def index
        @repairers = Repairer.all
        render json: @repairers, each_serializer: RepairerSerializer
      end

      def show
        render json: @repairer, serializer: RepairerSerializer
      end

      def availability
        date = params[:date].present? ? Date.parse(params[:date]) : Date.today
        time_slots = @repairer.available_time_slots(date)
        render json: { date: date, time_slots: time_slots }
      end

      # GET /api/v1/repairers/:repairer_id/calendar/:year/:month
      def calendar
        year = params[:year].to_i
        month = params[:month].to_i

        begin
          start_date = Date.new(year, month, 1)
          end_date = start_date.end_of_month
        rescue ArgumentError
          render json: { error: "Invalid year or month" }, status: :bad_request
          return
        end

        calendar_data = {}
        (start_date..end_date).each do |date|
          time_slots = @repairer.available_time_slots(date)
          calendar_data[date.to_s] = {
            available: time_slots.any? { |slot| slot[:available] }
            # You might want to include more details, like specific available slots
            # available_slots: time_slots.select { |slot| slot[:available] }
          }
        end

        render json: { year: year, month: month, calendar: calendar_data }
      end

      # GET /api/v1/repairers/nearby?latitude=...&longitude=...&radius=...
      def nearby
        latitude = params[:latitude]
        longitude = params[:longitude]
        radius = params[:radius]&.to_f || 10.0 # Default radius 10km

        unless latitude.present? && longitude.present?
          render json: { error: "Latitude and longitude are required" }, status: :bad_request
          return
        end

        begin
          lat_f = Float(latitude)
          lon_f = Float(longitude)
        rescue ArgumentError, TypeError
          render json: { error: "Invalid latitude or longitude format" }, status: :bad_request
          return
        end

        unless radius > 0
          render json: { error: "Radius must be a positive number" }, status: :bad_request
          return
        end

        @repairers = Repairer.near([ lat_f, lon_f ], radius, units: :km)
        render json: @repairers, each_serializer: RepairerSerializer
      end

      def destroy
        @repairer.destroy
        head :no_content
      end

      private

      def set_repairer
        @repairer = Repairer.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Repairer not found" }, status: :not_found
      end
    end
  end
end
