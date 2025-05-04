# == Schema Information
#
# Table name: api_tokens
#
#  id         :bigint           not null, primary key
#  expires_at :datetime
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_api_tokens_on_token    (token)
#  index_api_tokens_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :api_token do
    user
    token { SecureRandom.hex(32) }
    expires_at { 1.day.from_now }
  end
end
