# Create test users if they don't exist
user = User.find_by(email_address: "customer@example.com")
unless user
  puts "Creating test customer..."
  user = User.create!(
    name: "Test Customer",
    email_address: "customer@example.com",
    password: "password123",
    address: "123 Customer St, Sydney NSW 2000",
    latitude: -33.8688,
    longitude: 151.2093,
    onboarded: true,
    mobile_number: "0400123456"
  )
end

# Create test repairer if they don't exist
repairer = Repairer.find_by(email_address: "repairer@example.com")
unless repairer
  puts "Creating test repairer..."
  repairer = Repairer.create!(
    name: "Test Repairer",
    email_address: "repairer@example.com",
    password: "password123",
    hourly_rate: 50.0,
    service_radius: 30,
    address: "456 Repairer St, Sydney NSW 2000",
    latitude: -33.8700,
    longitude: 151.2100,
    professional: true,
    years_experience: 5,
    bio: "Experienced appliance repair technician specializing in home appliances."
  )

  # Add availability for the repairer for Monday through Friday, 9 AM to 5 PM
  (1..5).each do |day|
    Availability.create!(
      repairer: repairer,
      day_of_week: day,
      start_time: "09:00",
      end_time: "17:00"
    )
  end
end

# Create test appliances if they don't exist
puts "Creating test appliances..."
appliances = [
  { name: "Refrigerator", brand: "Samsung", model: "RF28R7351SG" },
  { name: "Washing Machine", brand: "LG", model: "WM3900HWA" },
  { name: "Dishwasher", brand: "Bosch", model: "SHEM63W55N" },
  { name: "Microwave", brand: "Panasonic", model: "NN-SN686S" },
  { name: "Air Conditioner", brand: "Daikin", model: "FTXR36TVJUA" }
]

created_appliances = []
appliances.each do |appliance_attrs|
  appliance = Appliance.find_by(name: appliance_attrs[:name], brand: appliance_attrs[:brand], model: appliance_attrs[:model])
  if appliance.nil?
    appliance = Appliance.create!(appliance_attrs)
    puts "Created #{appliance.name}"
  end
  created_appliances << appliance
end

# Create services for the repairer
puts "Creating test services..."
services = [
  {
    name: "Refrigerator Repair",
    description: "Diagnosis and repair of refrigerator issues including cooling problems, ice maker repairs, and compressor issues.",
    duration_minutes: 90,
    base_price: 120.00,
    appliance: created_appliances[0]
  },
  {
    name: "Washing Machine Repair",
    description: "Fixing common washing machine problems like leaks, drainage issues, and spin cycle problems.",
    duration_minutes: 60,
    base_price: 100.00,
    appliance: created_appliances[1]
  },
  {
    name: "Dishwasher Maintenance",
    description: "Regular maintenance and cleaning of dishwashers to prevent breakdowns and ensure optimal performance.",
    duration_minutes: 45,
    base_price: 80.00,
    appliance: created_appliances[2]
  },
  {
    name: "Microwave Repair",
    description: "Fixing microwave heating issues, turntable problems, and door repairs.",
    duration_minutes: 30,
    base_price: 60.00,
    appliance: created_appliances[3]
  },
  {
    name: "AC Service",
    description: "Air conditioner servicing including cleaning, refrigerant top-up, and fixing cooling issues.",
    duration_minutes: 120,
    base_price: 150.00,
    appliance: created_appliances[4]
  }
]

created_services = []
services.each do |service_attrs|
  service = Service.find_by(name: service_attrs[:name], repairer_id: repairer.id)
  if service.nil?
    service = repairer.services.create!(service_attrs)
    puts "Created service: #{service.name}"
  end
  created_services << service
end

# Create test bookings if they don't exist
puts "Creating test bookings..."
start_times = [
  1.day.from_now.change(hour: 10, min: 0),
  2.days.from_now.change(hour: 13, min: 0),
  3.days.from_now.change(hour: 15, min: 0)
]

statuses = [ "pending", "confirmed", "completed" ]
service_indices = [ 0, 1, 2 ]

bookings = []
3.times do |i|
  start_time = start_times[i]
  service = created_services[service_indices[i]]
  end_time = start_time + service.duration_minutes.minutes

  booking = Booking.find_by(
    user_id: user.id,
    repairer_id: repairer.id,
    service_id: service.id,
    start_time: start_time
  )

  unless booking
    booking = Booking.create!(
      user: user,
      repairer: repairer,
      service: service,
      start_time: start_time,
      end_time: end_time,
      status: statuses[i],
      address: user.address,
      notes: "Please fix my #{service.appliance.name} issue."
    )
    puts "Created booking for #{service.name} on #{start_time.strftime('%Y-%m-%d at %H:%M')}"
  end

  bookings << booking
end

# Create test messages for the first booking
puts "Creating test messages..."
first_booking = bookings.first

unless Message.where(booking_id: first_booking.id).exists?
  # User messages
  Message.create!(
    booking: first_booking,
    sender: user,
    content: "Hi, I'm having issues with my refrigerator. It's not cooling properly."
  )

  Message.create!(
    booking: first_booking,
    sender: user,
    content: "Will you need any special tools for this repair?"
  )

  # Repairer messages
  Message.create!(
    booking: first_booking,
    sender: repairer,
    content: "Hello! I'll check the cooling system and compressor for issues."
  )

  Message.create!(
    booking: first_booking,
    sender: repairer,
    content: "I'll bring my standard toolkit, which should be sufficient. Do you know when the problem started?"
  )

  Message.create!(
    booking: first_booking,
    sender: user,
    content: "It started about 3 days ago. The freezer is still working though."
  )

  puts "Created test messages for booking ##{first_booking.id}"
end

puts "Test data creation completed!"
