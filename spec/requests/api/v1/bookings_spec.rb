require 'rails_helper'
require 'swagger_helper'

RSpec.describe Api::V1::BookingsController, type: :request do
  include Rails.application.routes.url_helpers

  let!(:user) { create(:user) }
  let!(:repairer) { create(:repairer) }
  let!(:service) { create(:service, repairer: repairer) }
  let!(:availability) { create(:availability, repairer: repairer) }
  # Set start_time to next Monday at 10:00 AM
  let(:monday_10am) { Time.current.next_occurring(:monday).beginning_of_day + 10.hours }
  # Set start_time to next Monday at 13:00 PM - for the other user's booking
  let(:monday_1pm) { Time.current.next_occurring(:monday).beginning_of_day + 13.hours }
  let!(:booking) { create(:booking, user: user, repairer: repairer, service: service, start_time: monday_10am) }
  let(:headers) { { 'Authorization' => "Bearer #{user.generate_jwt}" } }

  path '/api/v1/bookings' do
    get 'Retrieves all bookings for the current user' do
      tags 'Bookings'
      produces 'application/json'
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'

      response '200', 'bookings found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   repairer_id: { type: :integer },
                   service_id: { type: :integer },
                   start_time: { type: :string, format: 'date-time' },
                   end_time: { type: :string, format: 'date-time' },
                   status: { type: :string },
                   address: { type: :string },
                   notes: { type: :string, nullable: true },
                   created_at: { type: :string, format: 'date-time' },
                   updated_at: { type: :string, format: 'date-time' }
                 },
                 required: %w[id repairer_id service_id start_time end_time status address]
               }

        let(:'Authorization') { headers['Authorization'] }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:'Authorization') { 'Bearer invalid_token' }
        run_test!
      end
    end

    post 'Creates a booking' do
      tags 'Bookings'
      consumes 'application/json'
      produces 'application/json'
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'
      parameter name: :booking_params, in: :body, schema: {
        type: :object,
        properties: {
          booking: {
            type: :object,
            properties: {
              repairer_id: { type: :integer },
              service_id: { type: :integer },
              start_time: { type: :string, format: 'date-time' },
              address: { type: :string },
              notes: { type: :string, nullable: true }
            },
            required: %w[repairer_id service_id start_time address]
          }
        }
      }

      response '201', 'booking created' do
        let(:'Authorization') { headers['Authorization'] }
        let(:booking_params) { { booking: { repairer_id: repairer.id, service_id: service.id, start_time: monday_1pm, address: Faker::Address.full_address } } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:'Authorization') { headers['Authorization'] }
        let(:booking_params) { { booking: { repairer_id: repairer.id, service_id: service.id, start_time: nil, address: nil } } }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:'Authorization') { 'Bearer invalid_token' }
        let(:booking_params) { { booking: { repairer_id: repairer.id, service_id: service.id, start_time: monday_1pm, address: Faker::Address.full_address } } }
        run_test!
      end
    end
  end

  path '/api/v1/bookings/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'ID of the booking'

    get 'Retrieves a booking' do
      tags 'Bookings'
      produces 'application/json'
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'

      response '200', 'booking found' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 repairer_id: { type: :integer },
                 service_id: { type: :integer },
                 start_time: { type: :string, format: 'date-time' },
                 end_time: { type: :string, format: 'date-time' },
                 status: { type: :string },
                 address: { type: :string },
                 notes: { type: :string, nullable: true },
                 created_at: { type: :string, format: 'date-time' },
                 updated_at: { type: :string, format: 'date-time' }
               },
               required: %w[id repairer_id service_id start_time end_time status address]

        let(:id) { booking.id }
        let(:'Authorization') { headers['Authorization'] }
        run_test!
      end

      response '404', 'booking not found' do
        let(:id) { 999 }
        let(:'Authorization') { headers['Authorization'] }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:id) { booking.id }
        let(:'Authorization') { 'Bearer invalid_token' }
        run_test!
      end
    end

    put 'Updates a booking' do
      tags 'Bookings'
      consumes 'application/json'
      produces 'application/json'
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'
      parameter name: :booking_params, in: :body, schema: {
        type: :object,
        properties: {
          booking: {
            type: :object,
            properties: {
              address: { type: :string },
              notes: { type: :string, nullable: true }
            }
          }
        }
      }

      response '200', 'booking updated' do
        let(:id) { booking.id }
        let(:'Authorization') { headers['Authorization'] }
        let(:booking_params) { { booking: { address: 'New Address', notes: 'Updated notes' } } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:id) { booking.id }
        let(:'Authorization') { headers['Authorization'] }
        let(:booking_params) { { booking: { start_time: nil } } }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:id) { booking.id }
        let(:'Authorization') { 'Bearer invalid_token' }
        let(:booking_params) { { booking: { address: 'New Address' } } }
        run_test!
      end
    end

    delete 'Cancels a booking' do
      tags 'Bookings'
      produces 'application/json'
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'

      response '204', 'booking cancelled' do
        let(:id) { booking.id }
        let(:'Authorization') { headers['Authorization'] }
        run_test!
      end

      response '404', 'booking not found' do
        let(:id) { 999 }
        let(:'Authorization') { headers['Authorization'] }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:id) { booking.id }
        let(:'Authorization') { 'Bearer invalid_token' }
        run_test!
      end
    end
  end
end
