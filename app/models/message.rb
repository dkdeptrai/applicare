# == Schema Information
#
# Table name: messages
#
#  id          :bigint           not null, primary key
#  content     :text
#  sender_type :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  booking_id  :bigint           not null
#  sender_id   :bigint           not null
#
# Indexes
#
#  index_messages_on_booking_id  (booking_id)
#  index_messages_on_sender      (sender_type,sender_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#
class Message < ApplicationRecord
  belongs_to :booking
  belongs_to :sender, polymorphic: true

  validates :content, presence: true

  after_create_commit :broadcast_message

  private

  def broadcast_message
    MessageBroadcastJob.perform_later(self)
  end

  def sender_name
    sender_type == "User" ? sender.name : sender.name
  end
end
