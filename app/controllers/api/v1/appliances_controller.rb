module Api
  module V1
    class AppliancesController < BaseController
      skip_before_action :authenticate_request, only: [ :index, :show ]
      before_action :set_appliance, only: [ :show, :update, :destroy, :bookings, :repair_history ]

      def index
        @appliances = Appliance.all
        render json: @appliances
      end

      def my_appliances
        @appliances = current_user.appliances.distinct
        render json: @appliances
      end

      def show
        render json: @appliance
      end

      def bookings
        @bookings = @appliance.bookings.where(user: current_user)
        render json: @bookings, each_serializer: BookingSerializer
      end

      def repair_history
        unless @appliance.user == current_user
          return render json: { error: "Not authorized" }, status: :forbidden
        end
        bookings = @appliance.bookings
        bookings = bookings.where(status: params[:status]) if params[:status].present?
        render json: bookings, each_serializer: BookingSerializer
      end

      def create
        @appliance = Appliance.new(appliance_params)
        @appliance.user = current_user

        if params[:image].present?
          begin
            result = Cloudinary::Uploader.upload(params[:image], folder: "appliances")
            @appliance.image_url = result["secure_url"]
          rescue Cloudinary::CloudinaryException => e
            return render json: { error: "Cloudinary upload failed: #{e.message}" }, status: :internal_server_error
          end
        end

        if @appliance.save
          render json: @appliance, status: :created
        else
          render json: { errors: @appliance.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if params[:image].present?
          begin
            result = Cloudinary::Uploader.upload(params[:image], folder: "appliances")
            params[:appliance] ||= {}
            params[:appliance][:image_url] = result["secure_url"]
          rescue Cloudinary::CloudinaryException => e
            return render json: { error: "Cloudinary upload failed: #{e.message}" }, status: :internal_server_error
          end
        end

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
        params.require(:appliance).permit(:name, :brand, :model, :image_url)
      end
    end
  end
end
