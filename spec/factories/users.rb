FactoryBot.define do
  factory :user do
    email_address { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    email_verified { false }
    email_verification_token { nil }
    email_verification_sent_at { nil }

    trait :verified do
      email_verified { true }
    end

    trait :unverified do
      email_verified { false }
      email_verification_token { SecureRandom.urlsafe_base64 }
      email_verification_sent_at { Time.current }
    end
  end
end
