FactoryBot.define do
  factory :api_token do
    user
    token { SecureRandom.hex(32) }
    expires_at { 1.day.from_now }
  end
end
