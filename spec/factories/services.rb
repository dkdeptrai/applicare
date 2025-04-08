FactoryBot.define do
  factory :service do
    association :repairer
    association :appliance
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    duration_minutes { [ 30, 60, 90, 120 ].sample }
    base_price { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
  end
end
