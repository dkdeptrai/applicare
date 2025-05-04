# == Schema Information
#
# Table name: services
#
#  id               :bigint           not null, primary key
#  base_price       :decimal(, )
#  description      :text
#  duration_minutes :integer
#  name             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  appliance_id     :bigint           not null
#  repairer_id      :bigint           not null
#
# Indexes
#
#  index_services_on_appliance_id  (appliance_id)
#  index_services_on_repairer_id   (repairer_id)
#
# Foreign Keys
#
#  fk_rails_...  (appliance_id => appliances.id)
#  fk_rails_...  (repairer_id => repairers.id)
#
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
