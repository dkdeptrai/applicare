require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  let(:test_user) { create(:user) }
  let(:token) { JwtToken.encode({ user_id: test_user.id }, exp: 7.days.from_now) }

  path '/api/v1/users/{id}' do
    get 'Retrieves a user' do
      tags 'Users'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string, description: 'ID of the user'
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'

      response '200', 'user found' do
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

        let(:id) { test_user.id }
        let(:'Authorization') { "Bearer #{token}" }
        run_test!
      end

      response '404', 'user not found' do
        let(:id) { 'invalid' }
        let(:'Authorization') { "Bearer #{token}" }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:id) { test_user.id }
        let(:'Authorization') { "Bearer invalid_token" }

        run_test! do
          expect(response.status).to eq 401
          expect(response.body).to include("Unauthorized")
        end
      end
    end

    put 'Updates a user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string, description: 'ID of the user'
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string },
              address: { type: :string },
              date_of_birth: { type: :string, format: 'date' },
              mobile_number: { type: :string },
              latitude: { type: :number, format: :float },
              longitude: { type: :number, format: :float }
            }
          }
        },
        required: [ 'user' ]
      }

      response '200', 'user updated' do
        let(:id) { test_user.id }
        let(:'Authorization') { "Bearer #{token}" }
        let(:user) do
          {
            user: {
              name: 'Updated Name',
              address: '123 Test Street',
              date_of_birth: '1990-01-01',
              mobile_number: '555-1234567',
              latitude: 40.7128,
              longitude: -74.0060
            }
          }
        end

        run_test! do |response|
          expect(response.status).to eq(200)
          data = JSON.parse(response.body)

          # Check that the data was updated
          expect(data['name']).to eq('Updated Name')
          expect(data['address']).to eq('123 Test Street')
          expect(data['date_of_birth']).to eq('1990-01-01')
          expect(data['mobile_number']).to eq('555-1234567')
          expect(data['latitude']).to eq(40.7128)
          expect(data['longitude']).to eq(-74.0060)

          # Check that onboarded is true since all required fields are provided
          expect(data['onboarded']).to eq(true)

          # Reload the user and check DB values
          test_user.reload
          expect(test_user.onboarded).to eq(true)
        end
      end

      response '403', 'forbidden - cannot update another user' do
        let(:another_user) { create(:user) }
        let(:id) { another_user.id }
        let(:'Authorization') { "Bearer #{token}" }
        let(:user) { { user: { name: 'Updated Name' } } }

        run_test! do |response|
          expect(response.status).to eq(403)
          data = JSON.parse(response.body)
          expect(data['error']).to eq('Unauthorized to update this user')
        end
      end

      response '401', 'unauthorized' do
        let(:id) { test_user.id }
        let(:'Authorization') { "Bearer invalid_token" }
        let(:user) { { user: { name: 'Updated Name' } } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:id) { test_user.id }
        let(:'Authorization') { "Bearer #{token}" }
        let(:user) { { user: { name: '' } } } # Empty name should fail validation

        run_test! do |response|
          expect(response.status).to eq(422)
          data = JSON.parse(response.body)
          expect(data['errors']).to include(/Name can't be blank/)
        end
      end
    end
  end

  path '/api/v1/users' do
    post 'Creates a user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string },
              email_address: { type: :string },
              password: { type: :string },
              password_confirmation: { type: :string }
            },
            required: %w[name email_address password password_confirmation]
          }
        }
      }

      response '201', 'user created' do
        let(:user) { { user: { name: 'Test User', email_address: 'new@example.com', password: 'password123', password_confirmation: 'password123' } } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:user) { { user: { email_address: 'invalid', password: 'short', password_confirmation: 'mismatch' } } }
        run_test!
      end
    end
  end
end
