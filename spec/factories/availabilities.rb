# == Schema Information
#
# Table name: availabilities
#
#  id          :bigint           not null, primary key
#  day_of_week :integer
#  end_time    :time
#  start_time  :time
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  repairer_id :bigint           not null
#
# Indexes
#
#  index_availabilities_on_repairer_id  (repairer_id)
#
# Foreign Keys
#
#  fk_rails_...  (repairer_id => repairers.id)
#
FactoryBot.define do
  factory :availability do
    # The repairer association should be created if not provided
    repairer
    day_of_week { 1 } # Monday
    start_time { '09:00' }
    end_time { '17:00' }
  end
end
