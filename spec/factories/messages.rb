# == Schema Information
#
# Table name: messages
#
#  id          :bigint           not null, primary key
#  content     :text
#  sender_type :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  booking_id  :bigint           not null
#  sender_id   :bigint           not null
#
# Indexes
#
#  index_messages_on_booking_id  (booking_id)
#  index_messages_on_sender      (sender_type,sender_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#
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
