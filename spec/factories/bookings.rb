# == Schema Information
#
# Table name: bookings
#
#  id          :bigint           not null, primary key
#  address     :text
#  end_time    :datetime
#  notes       :text
#  start_time  :datetime
#  status      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  repairer_id :bigint           not null
#  service_id  :bigint           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_bookings_on_repairer_id  (repairer_id)
#  index_bookings_on_service_id   (service_id)
#  index_bookings_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (repairer_id => repairers.id)
#  fk_rails_...  (service_id => services.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :booking do
    # Associations will be created if not provided
    repairer
    user
    service
    start_time { Time.current.next_occurring(:monday).change(hour: 10) }
    status { 'pending' }
    address { Faker::Address.full_address }

    # Calculate end_time only if start_time is present
    end_time do
      if start_time.present?
        start_time + (service&.duration_minutes || 60).minutes
      else
        nil # Or some other default if appropriate
      end
    end

    # Ensure availability exists for the booking time slot
    before(:create) do |booking|
      day_of_week = booking.start_time.wday
      # Check if availability already exists for this repairer and day
      unless booking.repairer.availabilities.exists?(day_of_week: day_of_week)
        # Create a broad availability slot for that day to ensure validation passes
        create(:availability,
               repairer: booking.repairer,
               day_of_week: day_of_week,
               start_time: booking.start_time.beginning_of_day,
               end_time: booking.start_time.end_of_day)
      end
    end

    trait :confirmed do
      status { 'confirmed' }
    end

    trait :cancelled do
      status { 'cancelled' }
    end

    trait :completed do
      status { 'completed' }
    end
  end
end
