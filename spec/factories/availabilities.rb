FactoryBot.define do
  factory :availability do
    # The repairer association should be created if not provided
    repairer
    day_of_week { 1 } # Monday
    start_time { '09:00' }
    end_time { '17:00' }
  end
end
