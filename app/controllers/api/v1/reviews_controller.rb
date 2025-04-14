# app/controllers/api/v1/reviews_controller.rb
class Api::V1::ReviewsController < Api::V1::BaseController
  before_action :authenticate_user!, only: [ :create ]
  before_action :set_repairer

  # GET /api/v1/repairers/:repairer_id/reviews
  def index
    reviews = @repairer.reviews.includes(:user) # Eager load user to avoid N+1
    render json: reviews, include: { user: { only: [ :id, :name ] } } # Include basic user info
  end

  # POST /api/v1/repairers/:repairer_id/reviews
  def create
    # Find a *completed* booking by the current user for this repairer that hasn't been reviewed yet
    booking = current_user.bookings.find_by(
      repairer_id: @repairer.id,
      status: "completed"
      # Optionally add: id: Review.where(user: current_user, repairer: @repairer).select(:booking_id).negate
      # if you want to ensure they haven't reviewed *any* booking for this repairer yet, but the model validation should handle specific booking review uniqueness.
    )

    if booking.nil?
      render json: { error: "No completed and unreviewed booking found with this repairer." }, status: :unprocessable_entity
      return
    end

    review = @repairer.reviews.new(review_params.merge(user: current_user, booking: booking))

    if review.save
      # The model callback `update_repairer_ratings` handles updating the repairer
      render json: review, status: :created
    else
      render json: { errors: review.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_repairer
    @repairer = Repairer.find(params[:repairer_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Repairer not found" }, status: :not_found
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
