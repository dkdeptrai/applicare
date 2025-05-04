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
class MessageSerializer < ActiveModel::Serializer
  attributes :id, :content, :created_at, :sender_type, :sender_id, :sender_info, :booking_id

  def sender_info
    {
      id: object.sender.id,
      name: object.sender.name,
      type: object.sender_type
    }
  end
end
