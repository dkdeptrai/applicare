FactoryBot.define do
  factory :repairer do
    name { Faker::Name.name }
    email_address { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    hourly_rate { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    service_radius { Faker::Number.between(from: 5, to: 50) }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
  end
end
