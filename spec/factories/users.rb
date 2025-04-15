FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email_address { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    onboarded { false }
    address { Faker::Address.full_address }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }

    trait :with_repairer do
      after(:create) do |user|
        create(:repairer, user: user)
      end
    end

    trait :onboarded do
      onboarded { true }
      date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65) }
      mobile_number { Faker::PhoneNumber.cell_phone }
    end
  end
end
