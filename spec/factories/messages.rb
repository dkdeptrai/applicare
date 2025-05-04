FactoryBot.define do
  factory :message do
    content { Faker::Lorem.sentence(word_count: 5) }
    association :booking

    # By default create as a user message, but can be overridden
    association :sender, factory: :user

    trait :from_user do
      association :sender, factory: :user
    end

    trait :from_repairer do
      association :sender, factory: :repairer
    end
  end
end
