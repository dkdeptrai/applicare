require 'swagger_helper'

RSpec.describe 'Api::V1::Repairer::Bookings', type: :request do
  # Define schemas for reusability
  let(:booking_schema) do
    {
      type: :object,
      properties: {
        id: { type: :integer },
        repairer_id: { type: :integer },
        user_id: { type: :integer },
        service_id: { type: :integer },
        start_time: { type: :string, format: 'date-time' },
        end_time: { type: :string, format: 'date-time' },
        status: { type: :string, enum: [ 'pending', 'confirmed', 'completed', 'cancelled' ] },
        address: { type: :string },
        notes: { type: :string, nullable: true },
        repairer_note: { type: :string, nullable: true },
        created_at: { type: :string, format: 'date-time' },
        updated_at: { type: :string, format: 'date-time' }
      },
      required: %w[id repairer_id user_id service_id start_time end_time status]
    }
  end

  # Test data setup
  let(:repairer) { create(:repairer) }
  let(:auth_token) { generate_repairer_jwt(repairer) }

  path '/api/v1/repairer/bookings' do
    get 'Lists all bookings for the authenticated repairer' do
      tags 'Repairer Bookings'
      produces 'application/json'
      security [ Bearer: [] ]
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'Bearer token'
      parameter name: :status, in: :query, schema: { type: :string, enum: [ 'pending', 'confirmed', 'completed', 'cancelled' ] }, required: false, description: 'Filter by booking status'
      parameter name: :start_date, in: :query, schema: { type: :string, format: :date }, required: false, description: 'Filter bookings from this date (YYYY-MM-DD)'
      parameter name: :end_date, in: :query, schema: { type: :string, format: :date }, required: false, description: 'Filter bookings until this date (YYYY-MM-DD)'

      response '200', 'bookings found' do
        schema type: :array, items: { '$ref': '#/components/schemas/booking' }

        before do
          # Create test bookings with different statuses and dates
          create(:booking, repairer: repairer, status: 'pending', start_time: Time.current.beginning_of_day + 9.hours)
          create(:booking, repairer: repairer, status: 'confirmed', start_time: Time.current.beginning_of_day + 14.hours)

          # Create booking for different repairer (should not be returned)
          create(:booking, repairer: create(:repairer), status: 'pending', start_time: Time.current.beginning_of_day + 10.hours)
        end

        let(:'Authorization') { "Bearer #{auth_token}" }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:'Authorization') { 'Bearer invalid_token' }
        run_test!
      end
    end
  end

  path '/api/v1/repairer/bookings/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true, description: 'Booking ID'

    get 'Retrieves a specific booking' do
      tags 'Repairer Bookings'
      produces 'application/json'
      security [ Bearer: [] ]
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'Bearer token'

      response '200', 'booking found' do
        schema '$ref': '#/components/schemas/booking'

        let(:booking) { create(:booking, repairer: repairer, start_time: Time.current.beginning_of_day + 9.hours) }
        let(:id) { booking.id }
        let(:'Authorization') { "Bearer #{auth_token}" }

        run_test!
      end

      response '404', 'booking not found' do
        let(:id) { 999999 }
        let(:'Authorization') { "Bearer #{auth_token}" }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:booking) { create(:booking, repairer: repairer, start_time: Time.current.beginning_of_day + 9.hours) }
        let(:id) { booking.id }
        let(:'Authorization') { 'Bearer invalid_token' }
        run_test!
      end
    end

    patch 'Updates a booking status' do
      tags 'Repairer Bookings'
      consumes 'application/json'
      produces 'application/json'
      security [ Bearer: [] ]
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'Bearer token'
      parameter name: :booking, in: :body, schema: {
        type: :object,
        properties: {
          booking: {
            type: :object,
            properties: {
              status: { type: :string, enum: [ 'confirmed', 'completed', 'cancelled' ] }
            },
            required: [ 'status' ]
          }
        },
        required: [ 'booking' ]
      }

      response '200', 'booking updated' do
        schema '$ref': '#/components/schemas/booking'

        let(:booking_object) { create(:booking, repairer: repairer, status: 'pending', start_time: Time.current.beginning_of_day + 9.hours) }
        let(:id) { booking_object.id }
        let(:'Authorization') { "Bearer #{auth_token}" }
        let(:booking) do
          {
            booking: {
              status: 'confirmed'
            }
          }
        end

        run_test!
      end

      response '422', 'invalid request' do
        let(:booking_obj) { create(:booking, repairer: repairer, status: 'pending', start_time: Time.current.beginning_of_day + 9.hours) }
        let(:id) { booking_obj.id }
        let(:'Authorization') { "Bearer #{auth_token}" }
        let(:booking) do
          {
            booking: {
              status: 'invalid_status'
            }
          }
        end

        run_test!
      end

      response '404', 'booking not found' do
        let(:id) { 999999 }
        let(:'Authorization') { "Bearer #{auth_token}" }
        let(:booking) do
          {
            booking: {
              status: 'confirmed'
            }
          }
        end

        run_test!
      end

      response '401', 'unauthorized' do
        let(:booking_obj) { create(:booking, repairer: repairer, status: 'pending', start_time: Time.current.beginning_of_day + 9.hours) }
        let(:id) { booking_obj.id }
        let(:'Authorization') { 'Bearer invalid_token' }
        let(:booking) do
          {
            booking: {
              status: 'confirmed'
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/repairer/bookings/{id}/notes' do
    parameter name: :id, in: :path, type: :integer, required: true, description: 'Booking ID'

    post 'Adds a note to a booking' do
      tags 'Repairer Bookings'
      consumes 'application/json'
      produces 'application/json'
      security [ Bearer: [] ]
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'Bearer token'
      parameter name: :note_params, in: :body, schema: {
        type: :object,
        properties: {
          note: { type: :string, description: 'Note content' }
        },
        required: [ 'note' ]
      }

      response '200', 'note added' do
        schema '$ref': '#/components/schemas/booking'

        let(:booking) { create(:booking, repairer: repairer, start_time: Time.current.beginning_of_day + 9.hours) }
        let(:id) { booking.id }
        let(:'Authorization') { "Bearer #{auth_token}" }
        let(:note_params) do
          {
            note: 'Customer requested early morning appointment'
          }
        end

        run_test!
      end

      response '422', 'invalid request' do
        let(:booking) { create(:booking, repairer: repairer, start_time: Time.current.beginning_of_day + 9.hours) }
        let(:id) { booking.id }
        let(:'Authorization') { "Bearer #{auth_token}" }
        let(:note_params) do
          {
            note: ''
          }
        end

        run_test!
      end

      response '404', 'booking not found' do
        let(:id) { 999999 }
        let(:'Authorization') { "Bearer #{auth_token}" }
        let(:note_params) do
          {
            note: 'Customer requested early morning appointment'
          }
        end

        run_test!
      end

      response '401', 'unauthorized' do
        let(:booking) { create(:booking, repairer: repairer, start_time: Time.current.beginning_of_day + 9.hours) }
        let(:id) { booking.id }
        let(:'Authorization') { 'Bearer invalid_token' }
        let(:note_params) do
          {
            note: 'Customer requested early morning appointment'
          }
        end

        run_test!
      end
    end
  end
end
