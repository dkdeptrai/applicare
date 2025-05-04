# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  address         :string           default("")
#  date_of_birth   :date
#  email_address   :string           not null
#  latitude        :float
#  longitude       :float
#  mobile_number   :string
#  name            :string           not null
#  onboarded       :boolean          default(FALSE)
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#
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
