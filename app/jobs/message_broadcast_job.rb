class MessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
    ActionCable.server.broadcast("chat_#{message.booking_id}", {
      id: message.id,
      content: message.content,
      sender_type: message.sender_type,
      sender_id: message.sender_id,
      sender_name: message.sender.name,
      created_at: message.created_at
    })
  end
end
