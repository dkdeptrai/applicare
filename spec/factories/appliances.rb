# == Schema Information
#
# Table name: appliances
#
#  id         :bigint           not null, primary key
#  brand      :string           not null
#  image_url  :string
#  model      :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_appliances_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :appliance do
    name { Faker::Appliance.equipment }
    brand { Faker::Appliance.brand }
    model { "#{Faker::Alphanumeric.alphanumeric(number: 2).upcase}#{Faker::Number.number(digits: 4)}" }
    image_url { nil }
    user

    trait :with_image do
      image_url { "https://res.cloudinary.com/sample/image/upload/v1234567890/appliances/sample_appliance_#{Faker::Number.number(digits: 4)}.jpg" }
    end
  end
end
