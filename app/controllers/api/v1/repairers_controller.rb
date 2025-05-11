module Api
  module V1
    class RepairersController < BaseController
      include JwtRepairerAuthenticable

      # Authentication/Authorization Order:
      # 1. Authenticate: Ensure a valid repairer JWT is present for protected actions
      # Authenticate first to get @current_repairer
      before_action :authenticate_repairer_request!, only: [ :upload_profile_picture, :upload_work_image, :delete_work_image, :destroy ]

      # 2. Set Instance Variable: Find the repairer specified by the ID in the path
      # For public/general actions, find normally. For protected actions, authorization is handled within the action.
      before_action :set_repairer_public, only: [ :show, :availability, :calendar ]
      # REMOVED :set_repairer for protected actions
      # REMOVED :authorize_repairer!

      def index
        @repairers = ::Repairer.all
        render json: @repairers, each_serializer: RepairerSerializer
      end

      def show
        render json: @repairer, serializer: RepairerSerializer # Uses @repairer set by set_repairer_public
      end

      def availability
        # Uses @repairer set by set_repairer_public
        date = params[:date].present? ? Date.parse(params[:date]) : Date.today
        time_slots = @repairer.available_time_slots(date)
        render json: { date: date, time_slots: time_slots }
      end

      # GET /api/v1/repairers/:repairer_id/calendar/:year/:month
      def calendar
        # Uses @repairer set by set_repairer_public
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
        # ... (nearby logic unchanged) ...
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

        @repairers = ::Repairer.near([ lat_f, lon_f ], radius, units: :km)
        render json: @repairers, each_serializer: RepairerSerializer
      end

      # POST /api/v1/repairers/:id/upload_profile_picture
      def upload_profile_picture
        # Combine find and authorize using @current_repairer
        @repairer = find_authorized_repairer(params[:id])
        return unless @repairer # Return if find_authorized_repairer rendered an error

        uploaded_file = params[:image]

        unless uploaded_file
          return render json: { error: "No image file provided" }, status: :bad_request
        end

        begin
          result = Cloudinary::Uploader.upload(uploaded_file.tempfile, folder: "repairer_profiles")
          if @repairer.profile_picture_id.present?
            Cloudinary::Uploader.destroy(@repairer.profile_picture_id)
          end
          if @repairer.update(profile_picture_id: result["public_id"])
            render json: { message: "Profile picture updated successfully", profile_picture_url: Cloudinary::Utils.cloudinary_url(result["public_id"], width: 200, height: 200, crop: :fill, gravity: :face, fetch_format: :auto) }, status: :ok
          else
            render json: { errors: @repairer.errors.full_messages }, status: :unprocessable_entity
          end
        rescue Cloudinary::CloudinaryException => e
          render json: { error: "Cloudinary upload failed: #{e.message}" }, status: :internal_server_error
        rescue => e
          render json: { error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
        end
      end

      # POST /api/v1/repairers/:id/upload_work_image
      def upload_work_image
        @repairer = find_authorized_repairer(params[:id])
        return unless @repairer

        uploaded_file = params[:image]

        unless uploaded_file
          return render json: { error: "No image file provided" }, status: :bad_request
        end

        begin
          result = Cloudinary::Uploader.upload(uploaded_file.tempfile, folder: "repairer_work_images")
          new_image_ids = @repairer.work_image_ids + [ result["public_id"] ]
          if @repairer.update(work_image_ids: new_image_ids)
            render json: { message: "Work image added successfully", work_image_urls: generate_work_image_urls(@repairer.reload.work_image_ids) }, status: :ok
          else
            render json: { errors: @repairer.errors.full_messages }, status: :unprocessable_entity
          end
        rescue Cloudinary::CloudinaryException => e
          render json: { error: "Cloudinary upload failed: #{e.message}" }, status: :internal_server_error
        rescue => e
          render json: { error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
        end
      end

      # DELETE /api/v1/repairers/:id/delete_work_image
      def delete_work_image
        @repairer = find_authorized_repairer(params[:id])
        return unless @repairer

        image_id_to_delete = params[:image_id]

        unless image_id_to_delete.present?
          return render json: { error: "Missing image_id parameter" }, status: :bad_request
        end

        unless @repairer.work_image_ids.include?(image_id_to_delete)
          return render json: { error: "Image ID not found for this repairer" }, status: :not_found
        end

        begin
          Cloudinary::Uploader.destroy(image_id_to_delete)
          updated_image_ids = @repairer.work_image_ids - [ image_id_to_delete ]
          if @repairer.update(work_image_ids: updated_image_ids)
            render json: { message: "Work image deleted successfully", work_image_urls: generate_work_image_urls(@repairer.reload.work_image_ids) }, status: :ok
          else
            render json: { errors: @repairer.errors.full_messages }, status: :unprocessable_entity
          end
        rescue Cloudinary::CloudinaryException => e
          Rails.logger.error("Cloudinary deletion failed for #{image_id_to_delete}: #{e.message}")
          updated_image_ids = @repairer.work_image_ids - [ image_id_to_delete ]
          if @repairer.update(work_image_ids: updated_image_ids)
            render json: { message: "Work image deleted from profile (Cloudinary deletion failed, check logs)", work_image_urls: generate_work_image_urls(@repairer.reload.work_image_ids) }, status: :ok
          else
             render json: { errors: @repairer.errors.full_messages }, status: :unprocessable_entity
          end
        rescue => e
          render json: { error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
        end
      end

      def destroy
        # Add authorization check here too if needed, or keep separate before_actions
        # Let's assume destroy also needs this pattern for consistency
        @repairer = find_authorized_repairer(params[:id])
        return unless @repairer

        # Consider deleting Cloudinary images associated with the repairer before destroying
        @repairer.destroy
        head :no_content
      end

      private

      # Renamed original set_repairer for clarity
      def set_repairer_public
        @repairer = ::Repairer.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Repairer not found" }, status: :not_found
      end

      # New method to find repairer ensuring it matches the authenticated user
      def find_authorized_repairer(id_param)
        # @current_repairer is set by authenticate_repairer_request!
        unless @current_repairer
          # This should technically be caught by authenticate_repairer_request!,
          # but defense in depth.
          render json: { error: "Authentication required" }, status: :unauthorized
          return nil
        end

        # Find the repairer by ID but *only if* it matches the authenticated repairer
        # Ensure we use integer ID for lookup
        target_id = id_param.to_i
        repairer = ::Repairer.find_by(id: target_id)

        # Explicitly compare integer IDs for robustness
        if repairer && @current_repairer && repairer.id == @current_repairer.id
          repairer # Return the found and authorized repairer
        elsif repairer # Found repairer, but doesn't match authenticated one
          Rails.logger.error("Authorization failed: Found repairer ID #{repairer.id} does not match authenticated repairer ID #{@current_repairer.id}")
          render json: { error: "Unauthorized" }, status: :unauthorized
          nil
        else # Repairer with given ID not found at all
          render json: { error: "Repairer not found" }, status: :not_found
          nil
        end
      end

      # Helper method to generate work image URLs (unchanged)
      def generate_work_image_urls(ids)
        ids.map do |public_id|
          Cloudinary::Utils.cloudinary_url(public_id, width: 400, quality: :auto, fetch_format: :auto)
        end
      end
    end
  end
end
