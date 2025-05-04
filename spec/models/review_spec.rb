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
require 'rails_helper'

RSpec.describe Review, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
