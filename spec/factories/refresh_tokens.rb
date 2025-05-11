# == Schema Information
#
# Table name: refresh_tokens
#
#  id          :bigint           not null, primary key
#  expires_at  :datetime
#  token       :string
#  used        :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  repairer_id :bigint
#  user_id     :bigint
#
# Indexes
#
#  index_refresh_tokens_on_repairer_id  (repairer_id)
#  index_refresh_tokens_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (repairer_id => repairers.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :refresh_token do
    token { SecureRandom.hex(32) }
    expires_at { 30.days.from_now }
    used { false }

    trait :for_user do
      association :user
      repairer_id { nil }
    end

    trait :for_repairer do
      association :repairer
      user_id { nil }
    end

    trait :expired do
      expires_at { 1.day.ago }
    end

    trait :used do
      used { true }
    end
  end
end
