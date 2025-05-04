#!/usr/bin/env ruby
require_relative 'config/environment'

# Find a suitable booking to test with
booking = Booking.first
if booking.nil?
  puts "No bookings found. Creating test data..."
  # Create test data if necessary
  user = User.first || User.create!(
    name: "Test User",
    email_address: "test_user_#{Time.now.to_i}@example.com",
    password: "password123",
    password_confirmation: "password123"
  )

  repairer = Repairer.first || Repairer.create!(
    name: "Test Repairer",
    email_address: "test_repairer_#{Time.now.to_i}@example.com",
    password: "password123",
    password_confirmation: "password123"
  )

  appliance = Appliance.first || Appliance.create!(
    name: "Test Appliance",
    brand: "Test Brand",
    model: "Test Model"
  )

  service = Service.first || Service.create!(
    repairer: repairer,
    appliance: appliance,
    title: "Test Service",
    description: "Test service description",
    price: 50,
    duration: 60
  )

  booking = Booking.create!(
    user: user,
    repairer: repairer,
    service: service,
    start_time: 1.day.from_now.change(hour: 10),
    end_time: 1.day.from_now.change(hour: 11),
    status: "confirmed",
    address: "123 Test St, Test City"
  )
else
  user = booking.user
  repairer = booking.repairer
end

puts "Testing chat for booking ##{booking.id}"
puts "User: #{user.name} (#{user.email_address})"
puts "Repairer: #{repairer.name} (#{repairer.email_address})"

# Create test messages
message_content = "Test message #{Time.now.to_i}"
puts "\nCreating message from user: #{message_content}"

message = user.messages.create!(
  booking: booking,
  content: message_content
)

puts "Message created with ID: #{message.id}"

# Verify message was created and broadcast works
puts "\nVerifying that message is in database..."
found_message = Message.find_by(id: message.id)
if found_message
  puts "✅ Message found in database with content: #{found_message.content}"
else
  puts "❌ Message not found in database!"
end

# Create test message from repairer
repairer_message_content = "Response from repairer #{Time.now.to_i}"
puts "\nCreating message from repairer: #{repairer_message_content}"

repairer_message = repairer.messages.create!(
  booking: booking,
  content: repairer_message_content
)

puts "Repairer message created with ID: #{repairer_message.id}"

# Print all messages for this booking
puts "\nAll messages for booking ##{booking.id}:"
booking.messages.order(created_at: :asc).each do |msg|
  sender = msg.sender_type == "User" ? "User" : "Repairer"
  puts "- #{sender}: #{msg.content} (#{msg.created_at.strftime('%Y-%m-%d %H:%M:%S')})"
end

puts "\nChat functionality test completed."
puts "To test in browser:"
puts "1. Start the Rails server: rails s"
puts "2. Open the application in a browser"
puts "3. Log in as user: #{user.email_address} / password123"
puts "4. Navigate to the booking details page"
puts "5. Try sending messages in the chat interface"
