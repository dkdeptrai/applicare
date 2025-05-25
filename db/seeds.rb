# db/seeds.rb

# Clean existing data (optional, useful for development)
puts "Cleaning database..."
Review.destroy_all
Booking.destroy_all
Availability.destroy_all
Service.destroy_all
Appliance.destroy_all
Repairer.destroy_all
User.destroy_all

puts "Creating Users..."
user1 = User.create!(name: "Alice Smith", email_address: "alice@example.com", password: "password123")
user2 = User.create!(name: "Bob Johnson", email_address: "bob@example.com", password: "password123")

puts "Creating Appliances..."
appliance_fridge = Appliance.create!(name: "Refrigerator", user: user1)
appliance_oven = Appliance.create!(name: "Oven", user: user1)
appliance_washer = Appliance.create!(name: "Washing Machine", user: user1)

puts "Creating Repairers..."
repairer1 = Repairer.create!(
  name: "Ricardo Rodriguez",
  email_address: "ricardo@example.com",
  password: "password123",
  hourly_rate: 75.50,
  service_radius: 20,
  address: "123 Main St, Anytown, USA", # Add address for geocoding
  professional: true,
  years_experience: 10,
  bio: "Experienced refrigeration technician specializing in all major brands. Reliable and efficient service.",
  profile_picture_id: "sample_repairer_profile_1", # Placeholder Cloudinary ID
  work_image_ids: [ "sample_repairer_work_1a", "sample_repairer_work_1b" ] # Placeholder Cloudinary IDs
)

repairer2 = Repairer.create!(
  name: "Sarah Chen",
  email_address: "sarah@example.com",
  password: "password123",
  hourly_rate: 60.00,
  service_radius: 15,
  address: "456 Oak Ave, Anytown, USA", # Add address for geocoding
  professional: false,
  years_experience: 3,
  bio: "General appliance repair expert. Friendly service for ovens, washers, and more.",
  profile_picture_id: "sample_repairer_profile_2"
)

puts "Creating Services..."
service_fridge_repair = repairer1.services.create!(appliance: appliance_fridge, description: "Standard refrigerator diagnosis and repair", duration_minutes: 90)
service_oven_repair = repairer2.services.create!(appliance: appliance_oven, description: "Oven heating element replacement", duration_minutes: 60)
service_washer_repair = repairer2.services.create!(appliance: appliance_washer, description: "Washing machine leak check and repair", duration_minutes: 75)

puts "Creating Availabilities..."
# Example: Repairer 1 available Mon-Fri 8am-5pm
(1..5).each do |day|
  repairer1.availabilities.create!(day_of_week: day, start_time: Time.zone.parse("08:00"), end_time: Time.zone.parse("17:00"))
end
# Example: Repairer 2 available Tue-Sat 9am-6pm
(2..6).each do |day|
  repairer2.availabilities.create!(day_of_week: day, start_time: Time.zone.parse("09:00"), end_time: Time.zone.parse("18:00"))
end

puts "Creating Bookings..."
# Completed booking for user1 with repairer1
booking1 = Booking.create!(
  user: user1,
  repairer: repairer1,
  service: service_fridge_repair,
  start_time: 2.days.ago.change(hour: 10),
  end_time: 2.days.ago.change(hour: 10) + service_fridge_repair.duration_minutes.minutes,
  status: 'completed',
  address: "10 Downing St, London SW1A 2AA"
)

# Pending booking for user2 with repairer2
booking2 = Booking.create!(
  user: user2,
  repairer: repairer2,
  service: service_oven_repair,
  start_time: 1.day.from_now.change(hour: 14),
  end_time: 1.day.from_now.change(hour: 14) + service_oven_repair.duration_minutes.minutes,
  status: 'confirmed',
  address: "Buckingham Palace Rd, London SW1A 1AA"
)

# Completed booking for user1 with repairer2
booking3 = Booking.create!(
  user: user1,
  repairer: repairer2,
  service: service_washer_repair,
  start_time: 3.days.ago.change(hour: 9),
  end_time: 3.days.ago.change(hour: 9) + service_washer_repair.duration_minutes.minutes,
  status: 'completed',
  address: "221B Baker St, London NW1 6XE"
)

puts "Creating Reviews..."
# Review for booking1 (user1 reviewing repairer1)
Review.create!(
  user: user1,
  repairer: repairer1,
  booking: booking1,
  rating: 5,
  comment: "Ricardo was fantastic! Fixed my fridge quickly and professionally. Highly recommend."
)

# Review for booking3 (user1 reviewing repairer2)
Review.create!(
  user: user1,
  repairer: repairer2,
  booking: booking3,
  rating: 4,
  comment: "Sarah did a good job fixing the washer. Was a bit late, but communicated well."
)

puts "Seed data created successfully!"

# Note: The review callback will automatically update repairer ratings/counts.
