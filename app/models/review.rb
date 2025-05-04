# == Schema Information
#
# Table name: reviews
#
#  id          :bigint           not null, primary key
#  comment     :text
#  rating      :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  booking_id  :bigint           not null
#  repairer_id :bigint           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_reviews_on_booking_id   (booking_id)
#  index_reviews_on_repairer_id  (repairer_id)
#  index_reviews_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (repairer_id => repairers.id)
#  fk_rails_...  (user_id => users.id)
#
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
