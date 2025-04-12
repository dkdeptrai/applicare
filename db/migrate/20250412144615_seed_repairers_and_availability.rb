class SeedRepairersAndAvailability < ActiveRecord::Migration[7.1]
  def change
    # Create Repairers
    repairer1 = Repairer.create!(
      name: 'John Doe',
      email_address: 'john.doe@example.com',
      password: 'password',
      password_confirmation: 'password',
      hourly_rate: 50.0,
      service_radius: 20.0
    )

    repairer2 = Repairer.create!(
      name: 'Jane Smith',
      email_address: 'jane.smith@example.com',
      password: 'password',
      password_confirmation: 'password',
      hourly_rate: 55.0,
      service_radius: 25.0
    )

    # Define standard availability times
    start_time = Time.parse('09:00:00')
    end_time = Time.parse('17:00:00')

    # Create Availability for Repairer 1 (Monday to Friday)
    (1..5).each do |day|
      Availability.create!(
        repairer: repairer1,
        day_of_week: day,
        start_time: start_time,
        end_time: end_time
      )
    end

    # Create Availability for Repairer 2 (Monday to Friday)
    (1..5).each do |day|
      Availability.create!(
        repairer: repairer2,
        day_of_week: day,
        start_time: start_time,
        end_time: end_time
      )
    end
  end
end
