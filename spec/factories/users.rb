FactoryBot.define do
  factory :user do
    email_address { Faker::Internet.email }
    password_digest { Faker::Internet.password }
  end
end
