FactoryBot.define do
  factory :appliance do
    name { Faker::Appliance.equipment }
    brand { Faker::Company.name }
    model { Faker::Alphanumeric.alphanumeric(number: 10) }
  end
end
