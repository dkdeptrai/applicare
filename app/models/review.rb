class Review < ApplicationRecord
  belongs_to :user
  belongs_to :repairer
  belongs_to :booking

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, presence: true
  validates :booking_id, uniqueness: { scope: :user_id, message: "has already been reviewed by you" }

  validate :booking_belongs_to_user
  validate :booking_is_completed

  after_commit :update_repairer_ratings, on: [ :create, :update, :destroy ]
  # Consider using after_destroy as well if reviews can be deleted

  private

  def booking_belongs_to_user
    return unless user && booking
    errors.add(:booking, "does not belong to the current user") if booking.user_id != user.id
  end

  def booking_is_completed
    return unless booking
    # Adjust "completed" if your status is different
    errors.add(:booking, "must be completed before reviewing") unless booking.status == "completed"
  end

  def update_repairer_ratings
    # Ensure repairer association is loaded
    repairer.reload

    # Calculate new average and count
    reviews = repairer.reviews
    new_count = reviews.count
    new_average = new_count > 0 ? reviews.average(:rating).round(2) : 0

    # Update the repairer record directly to avoid callbacks
    repairer.update_columns(reviews_count: new_count, ratings_average: new_average)
  end
end
