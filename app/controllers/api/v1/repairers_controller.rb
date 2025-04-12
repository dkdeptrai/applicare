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
