require 'swagger_helper'

RSpec.describe 'Customers API', type: :request do
  let(:repairer) { create(:repairer) }
  let(:user1) { create(:user, name: 'Customer One') }
  let(:user2) { create(:user, name: 'Customer Two') }
  let(:token) { JwtToken.encode({ repairer_id: repairer.id }, exp: 7.days.from_now) }
  let(:Authorization) { "Bearer #{token}" }

  # Create bookings to establish customer-repairer relationships
  before do
    service = create(:service, repairer: repairer, duration_minutes: 60)

    # Create repairer availability for every day of the week
    (0..6).each do |day|
      create(:availability,
             repairer: repairer,
             day_of_week: day,
             start_time: Time.parse('08:00'),
             end_time: Time.parse('18:00'))
    end

    # Create bookings with different time slots to avoid conflict
    tomorrow = DateTime.now + 1.day
    tomorrow = tomorrow.change(hour: 10, min: 0) # Set to 10 AM to be within availability

    create(:booking,
           user: user1,
           repairer: repairer,
           service: service,
           start_time: tomorrow,
           address: '123 First Street',
           status: 'confirmed')

    day_after_tomorrow = DateTime.now + 2.days
    day_after_tomorrow = day_after_tomorrow.change(hour: 14, min: 0) # Set to 2 PM to be within availability

    create(:booking,
           user: user2,
           repairer: repairer,
           service: service,
           start_time: day_after_tomorrow,
           address: '456 Second Street',
           status: 'confirmed')
  end

  path '/api/v1/customers' do
    get 'Retrieves all customers for the authenticated repairer' do
      tags 'Customers'
      produces 'application/json'
      security [ Bearer: [] ]
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token for repairer authentication'

      response '200', 'customers found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   email_address: { type: :string },
                   address: { type: :string },
                   date_of_birth: { type: :string, format: 'date', nullable: true },
                   mobile_number: { type: :string, nullable: true },
                   latitude: { type: :number, format: :float, nullable: true },
                   longitude: { type: :number, format: :float, nullable: true },
                   onboarded: { type: :boolean },
                   created_at: { type: :string, format: 'date-time' },
                   updated_at: { type: :string, format: 'date-time' }
                 },
                 required: %w[id name email_address onboarded]
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.length).to eq(2)
          expect(data.map { |c| c['name'] }).to include('Customer One', 'Customer Two')
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { "Bearer invalid_token" }
        run_test!
      end

      response '403', 'forbidden - not a repairer' do
        let(:user_token) { JwtToken.encode({ user_id: user1.id }, exp: 7.days.from_now) }
        let(:Authorization) { "Bearer #{user_token}" }

        run_test! do |response|
          expect(response.status).to eq(403)
          data = JSON.parse(response.body)
          expect(data['error']).to eq('Only repairers can access customer information')
        end
      end
    end
  end

  path '/api/v1/customers/{id}' do
    get 'Retrieves a specific customer' do
      tags 'Customers'
      produces 'application/json'
      security [ Bearer: [] ]
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token for repairer authentication'
      parameter name: :id, in: :path, type: :string, description: 'ID of the customer'

      response '200', 'customer found' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 email_address: { type: :string },
                 address: { type: :string },
                 date_of_birth: { type: :string, format: 'date', nullable: true },
                 mobile_number: { type: :string, nullable: true },
                 latitude: { type: :number, format: :float, nullable: true },
                 longitude: { type: :number, format: :float, nullable: true },
                 onboarded: { type: :boolean },
                 created_at: { type: :string, format: 'date-time' },
                 updated_at: { type: :string, format: 'date-time' }
               },
               required: %w[id name email_address onboarded]

        let(:id) { user1.id }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(user1.id)
          expect(data['name']).to eq('Customer One')
        end
      end

      response '404', 'customer not found or not associated with repairer' do
        let(:another_user) { create(:user) } # User with no bookings with this repairer
        let(:id) { another_user.id }

        run_test! do |response|
          expect(response.status).to eq(404)
          data = JSON.parse(response.body)
          expect(data['error']).to eq('Customer not found or not associated with this repairer')
        end
      end

      response '401', 'unauthorized' do
        let(:id) { user1.id }
        let(:Authorization) { "Bearer invalid_token" }
        run_test!
      end

      response '403', 'forbidden - not a repairer' do
        let(:id) { user1.id }
        let(:user_token) { JwtToken.encode({ user_id: user1.id }, exp: 7.days.from_now) }
        let(:Authorization) { "Bearer #{user_token}" }

        run_test! do |response|
          expect(response.status).to eq(403)
        end
      end
    end
  end

  path '/api/v1/customers/{id}/bookings' do
    get "Retrieves a customer's bookings with the repairer" do
      tags 'Customers'
      produces 'application/json'
      security [ Bearer: [] ]
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token for repairer authentication'
      parameter name: :id, in: :path, type: :string, description: 'ID of the customer'

      response '200', 'bookings found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   repairer_id: { type: :integer },
                   user_id: { type: :integer },
                   service_id: { type: :integer },
                   start_time: { type: :string, format: 'date-time' },
                   end_time: { type: :string, format: 'date-time' },
                   status: { type: :string, enum: [ 'pending', 'confirmed', 'cancelled', 'completed' ] },
                   address: { type: :string },
                   notes: { type: :string, nullable: true },
                   repairer_note: { type: :string, nullable: true },
                   created_at: { type: :string, format: 'date-time' },
                   updated_at: { type: :string, format: 'date-time' }
                 },
                 required: %w[id repairer_id user_id service_id start_time end_time status]
               }

        let(:id) { user1.id }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.length).to eq(1)
          expect(data[0]['user_id']).to eq(user1.id)
          expect(data[0]['repairer_id']).to eq(repairer.id)
        end
      end

      response '404', 'customer not found or not associated with repairer' do
        let(:another_user) { create(:user) } # User with no bookings with this repairer
        let(:id) { another_user.id }

        run_test! do |response|
          expect(response.status).to eq(404)
        end
      end

      response '401', 'unauthorized' do
        let(:id) { user1.id }
        let(:Authorization) { "Bearer invalid_token" }
        run_test!
      end
    end
  end
end
