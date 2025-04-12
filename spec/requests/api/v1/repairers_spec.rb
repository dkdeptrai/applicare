require 'swagger_helper'

RSpec.describe 'Api::V1::Repairers', type: :request do
  path '/api/v1/repairers/{repairer_id}/calendar/{year}/{month}' do
    # You'll want to customize the parameter details based on your setup
    parameter name: 'repairer_id', in: :path, type: :string, description: 'ID of the repairer'
    parameter name: 'year', in: :path, type: :integer, description: 'Year for the calendar view'
    parameter name: 'month', in: :path, type: :integer, description: 'Month for the calendar view (1-12)'

    get('Retrieves the monthly availability calendar for a repairer') do
      tags 'Repairers'
      produces 'application/json'
      # Add security definitions if needed (e.g., authentication token)
      security [ Bearer: [] ] # Define Bearer token security

      let(:user) { create(:user, name: 'Test User', email_address: 'testuser@example.com', password: 'password') } # Use FactoryBot create
      let(:token) { JwtToken.encode({ user_id: user.id }) } # Generate JWT token

      let(:repairer) { create(:repairer, name: 'Test Repairer', email_address: 'test@example.com', password: 'password', password_confirmation: 'password', hourly_rate: 60, service_radius: 15) } # Add password_confirmation back
      let(:repairer_id) { repairer.id }
      let(:year) { 2025 }
      let(:month) { 4 } # April

      # Seed availability for the test repairer (e.g., Mon-Fri 9-5)
      before do
        start_time = Time.parse('09:00:00')
        end_time = Time.parse('17:00:00')
        (1..5).each do |day|
          create(:availability, repairer: repairer, day_of_week: day, start_time: start_time, end_time: end_time)
        end
        # Optional: Seed a booking to test unavailability
        # booking_start = DateTime.new(year, month, 15, 10, 0, 0) # Example: April 15th, 10:00 AM
        # Booking.create!(repairer: repairer, user: User.create!(email: 'user@example.com', password: 'password'), start_time: booking_start, end_time: booking_start + 1.hour, status: 'confirmed')
      end

      response(200, 'successful') do
        let(:Authorization) { "Bearer #{token}" } # Add Authorization header definition here

        schema type: :object,
               properties: {
                 year: { type: :integer, example: 2025 },
                 month: { type: :integer, example: 4 },
                 calendar: {
                   type: :object,
                   additionalProperties: {
                     type: :object,
                     properties: {
                       available: { type: :boolean, description: 'Indicates if the repairer has any availability on this day' }
                       # Add other properties if your controller returns more details
                     },
                     required: [ 'available' ]
                   },
                   description: 'Object mapping dates (YYYY-MM-DD) to their availability status'
                 }
               },
               required: %w[year month calendar]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['year']).to eq(year)
          expect(data['month']).to eq(month)
          expect(data['calendar']).to be_a(Hash)
          # Example check: Verify a specific date's availability based on seeded data
          # Date for Tuesday, April 1st, 2025 (should be available based on seed)
          expect(data['calendar']['2025-04-01']['available']).to eq(true)
          # Date for Sunday, April 6th, 2025 (should be unavailable)
          expect(data['calendar']['2025-04-06']['available']).to eq(false)
          # Add more specific checks based on seeded bookings if any
        end
      end

      response(400, 'invalid parameters') do
        let(:Authorization) { "Bearer #{token}" } # Ensure Authorization header is defined here
        let(:month) { 13 } # Invalid month
        run_test!
      end

      response(404, 'repairer not found') do
        let(:Authorization) { "Bearer #{token}" } # Ensure Authorization header is defined here
        let(:repairer_id) { 'invalid-id' }
        run_test!
      end

      # Add tests for authentication if required
      response(401, 'unauthorized') do
        let(:'Authorization') { 'Bearer invalid_token' } # Test with an invalid token - also use symbol
        run_test!
      end

      response(401, 'token not provided') do
         let(:'Authorization') { nil } # Test without providing token - also use symbol
         run_test!
      end
    end
  end
end
