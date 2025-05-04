module Api
  module V1
    class AppliancesController < BaseController
      skip_before_action :authenticate_request, only: [ :index, :show ]
      before_action :set_appliance, only: [ :show, :update, :destroy ]

      def index
        @appliances = Appliance.all
        render json: @appliances
      end

      def show
        render json: @appliance
      end

      def create
        @appliance = Appliance.new(appliance_params)

        if @appliance.save
          render json: @appliance, status: :created
        else
          render json: { errors: @appliance.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @appliance.update(appliance_params)
          render json: @appliance
        else
          render json: { errors: @appliance.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @appliance.destroy
          head :no_content
        else
          render json: { errors: @appliance.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_appliance
        @appliance = Appliance.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Appliance not found" }, status: :not_found
      end

      def appliance_params
        params.require(:appliance).permit(:name, :brand, :model)
      end
    end
  end
end
