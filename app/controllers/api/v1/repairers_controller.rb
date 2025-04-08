module Api
  module V1
    class RepairersController < BaseController
      before_action :authenticate_user!
      before_action :set_repairer, only: [ :show, :update, :destroy, :availability ]

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

      private

      def set_repairer
        @repairer = Repairer.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Repairer not found" }, status: :not_found
      end
    end
  end
end
