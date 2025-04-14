FactoryBot.define do
  factory :review do
    rating { Faker::Number.between(from: 1, to: 5) }
    comment { Faker::Lorem.sentence }
    association :user
    association :repairer
    association :booking
  end
end
