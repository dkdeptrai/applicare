FactoryBot.define do
  factory :booking do
    # Associations will be created if not provided
    repairer
    user
    service
    start_time { Time.current.next_occurring(:monday).beginning_of_day + 10.hours }
    status { 'pending' }
    address { Faker::Address.full_address }

    trait :confirmed do
      status { 'confirmed' }
    end

    trait :cancelled do
      status { 'cancelled' }
    end

    trait :completed do
      status { 'completed' }
    end

    # Ensure end_time is set based on service duration
    after(:build) do |booking|
      if booking.service && booking.start_time && !booking.end_time
        booking.end_time = booking.start_time + booking.service.duration_minutes.minutes
      end
    end
  end
end
