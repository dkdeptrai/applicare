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
require 'rails_helper'

RSpec.describe RefreshToken, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
