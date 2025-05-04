class ChatChannel < ApplicationCable::Channel
  def subscribed
    booking_id = params[:booking_id]
    booking = Booking.find_by(id: booking_id)

    if booking && authorized?(booking)
      stream_from "chat_#{booking_id}"
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    booking_id = params[:booking_id]
    booking = Booking.find_by(id: booking_id)

    return unless booking && authorized?(booking)

    # Create the message
    current_entity.messages.create!(
      booking: booking,
      content: data["content"]
    )
  end

  private

  def authorized?(booking)
    # Check if the current entity (user or repairer) is associated with this booking
    if current_entity.is_a?(User)
      booking.user_id == current_entity.id
    elsif current_entity.is_a?(Repairer)
      booking.repairer_id == current_entity.id
    else
      false
    end
  end

  def current_entity
    connection.current_entity
  end
end
