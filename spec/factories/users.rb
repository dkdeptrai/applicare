FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email_address { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }

    trait :with_repairer do
      after(:create) do |user|
        create(:repairer, user: user)
      end
    end
  end
end
