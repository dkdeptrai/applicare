require 'swagger_helper'

RSpec.describe 'Api::V1::Repairers', type: :request do
  # Align JWT generation with bookings_spec
  let(:user) { create(:user) }
  # Remove the separate token let, generate directly in auth_headers
  let(:auth_headers) { { 'Authorization' => "Bearer #{user.generate_jwt}" } }

  path '/api/v1/repairers/{repairer_id}/calendar/{year}/{month}' do
    parameter name: 'repairer_id', in: :path, type: :string, description: 'ID of the repairer'
    parameter name: 'year', in: :path, type: :integer, description: 'Year for the calendar view'
    parameter name: 'month', in: :path, type: :integer, description: 'Month for the calendar view (1-12)'
    parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'

    get('Retrieves the monthly availability calendar for a repairer') do
      tags 'Repairers'
      produces 'application/json'
      security [ Bearer: [] ]

      let(:repairer) { create(:repairer) }
      let(:repairer_id) { repairer.id }
      let(:year) { 2025 }
      let(:month) { 4 }

      before do
        start_time = Time.parse('09:00:00')
        end_time = Time.parse('17:00:00')
        (1..5).each do |day|
          create(:availability, repairer: repairer, day_of_week: day, start_time: start_time, end_time: end_time)
        end
      end

      response(200, 'successful') do
        let(:'Authorization') { auth_headers['Authorization'] }

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
        let(:'Authorization') { auth_headers['Authorization'] }
        let(:month) { 13 }
        run_test!
      end

      response(404, 'repairer not found') do
        let(:'Authorization') { auth_headers['Authorization'] }
        let(:repairer_id) { 'invalid-id' }
        run_test!
      end

      response(401, 'unauthorized - invalid token') do
        let(:'Authorization') { 'Bearer invalid_token' }
        run_test!
      end

      response(401, 'unauthorized - no token') do
        # Explicitly set Authorization to nil for this test
        let(:'Authorization') { nil }
        run_test!
      end
    end
  end

  path '/api/v1/repairers/nearby' do
    parameter name: :latitude, in: :query, type: :number, format: :float, required: true, description: 'User\'s latitude'
    parameter name: :longitude, in: :query, type: :number, format: :float, required: true, description: 'User\'s longitude'
    parameter name: :radius, in: :query, type: :number, format: :float, required: false, description: 'Search radius in kilometers (default: 10)'
    parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'

    get('Finds repairers near a given location') do
      tags 'Repairers'
      produces 'application/json'
      security [ Bearer: [] ]

      # Define test locations and repairers
      let(:user_lat) { 40.7128 }
      let(:user_lon) { -74.0060 } # New York City
      let!(:nearby_repairer1) { create(:repairer, latitude: 40.7130, longitude: -74.0050) }
      let!(:nearby_repairer2) { create(:repairer, latitude: 40.7580, longitude: -73.9855) }
      let!(:far_repairer) { create(:repairer, latitude: 34.0522, longitude: -118.2437) }

      response(200, 'successful') do
        let(:'Authorization') { auth_headers['Authorization'] }
        let(:latitude) { user_lat }
        let(:longitude) { user_lon }
        # Default radius
        schema type: :array, items: { '$ref' => '#/components/schemas/repairer' }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq(2)
          repairer_ids = data.map { |r| r['id'] }
          expect(repairer_ids).to include(nearby_repairer1.id, nearby_repairer2.id)
          expect(repairer_ids).not_to include(far_repairer.id)
        end
      end

      response(200, 'successful with custom radius') do
        let(:'Authorization') { auth_headers['Authorization'] }
        let(:latitude) { user_lat }
        let(:longitude) { user_lon }
        let(:radius) { 1 }
        schema type: :array, items: { '$ref' => '#/components/schemas/repairer' }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq(1)
          expect(data.first['id']).to eq(nearby_repairer1.id)
        end
      end

      response(200, 'successful - no repairers found') do
        let(:'Authorization') { auth_headers['Authorization'] }
        let(:latitude) { 0 }
        let(:longitude) { 0 }
        let(:radius) { 1 }
        schema type: :array, items: { '$ref' => '#/components/schemas/repairer' }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq(0)
        end
      end

      response(400, 'missing latitude') do
        let(:'Authorization') { auth_headers['Authorization'] }
        let(:longitude) { user_lon }
        let(:latitude) { nil } # Explicitly set to nil
        run_test!
      end

      response(400, 'missing longitude') do
        let(:'Authorization') { auth_headers['Authorization'] }
        let(:latitude) { user_lat }
        let(:longitude) { nil } # Explicitly set to nil
        run_test!
      end

      response(400, 'invalid latitude format') do
        let(:'Authorization') { auth_headers['Authorization'] }
        let(:latitude) { 'invalid' }
        let(:longitude) { user_lon }
        run_test!
      end

      response(400, 'invalid longitude format') do
        let(:'Authorization') { auth_headers['Authorization'] }
        let(:latitude) { user_lat }
        let(:longitude) { 'invalid' }
        run_test!
      end

       response(400, 'invalid radius') do
        let(:'Authorization') { auth_headers['Authorization'] }
        let(:latitude) { user_lat }
        let(:longitude) { user_lon }
        let(:radius) { -5 }
        run_test!
      end

      response(401, 'unauthorized - invalid token') do
        let(:'Authorization') { 'Bearer invalid' }
        # Params required even for auth failure if defined in swagger
        let(:latitude) { user_lat }
        let(:longitude) { user_lon }
        run_test!
      end

       response(401, 'unauthorized - no token') do
        # Explicitly set Authorization to nil
        let(:'Authorization') { nil }
        # Params still needed if required by swagger
        let(:latitude) { user_lat }
        let(:longitude) { user_lon }
        run_test!
       end
    end
  end
end
