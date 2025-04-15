require 'swagger_helper'

RSpec.describe 'Profile API', type: :request do
  path '/api/v1/profile' do
    get('Retrieves the current user profile') do
      tags 'Profile'
      produces 'application/json'
      security [ Bearer: [] ]
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'

      response(200, 'successful') do
        let(:user) { create(:user, name: 'Test User', email_address: 'profile@test.com', address: '') } # Create with empty address
        let(:auth_headers) { { 'Authorization' => "Bearer #{user.generate_jwt}" } }
        let(:'Authorization') { auth_headers['Authorization'] }

        # Define the expected schema based on UserSerializer
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 email_address: { type: :string, format: :email },
                 address: { type: :string },
                 latitude: { type: :number, format: :float, nullable: true },
                 longitude: { type: :number, format: :float, nullable: true },
                 date_of_birth: { type: :string, format: 'date', nullable: true },
                 mobile_number: { type: :string, nullable: true },
                 onboarded: { type: :boolean },
                 created_at: { type: :string, format: 'date-time' },
                 updated_at: { type: :string, format: 'date-time' }
               },
               required: [ 'id', 'name', 'email_address', 'address', 'onboarded', 'created_at', 'updated_at' ]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(user.id)
          expect(data['name']).to eq('Test User')
          expect(data['email_address']).to eq('profile@test.com')
          expect(data['address']).to eq('') # Default address
          expect(data['onboarded']).to eq(false) # Default onboarded status
          # Check other fields if needed
        end
      end

      response(401, 'unauthorized - invalid token') do
        let(:'Authorization') { 'Bearer invalid_token' }
        run_test!
      end

      response(401, 'unauthorized - no token') do
        let(:'Authorization') { nil }
        run_test!
      end
    end

    put('Updates the current user profile') do
      tags 'Profile'
      consumes 'application/json'
      produces 'application/json'
      security [ Bearer: [] ]
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

      response(200, 'profile updated successfully') do
        let(:profile_user) { create(:user, name: 'Test User', email_address: 'profile@test.com') }
        let(:auth_headers) { { 'Authorization' => "Bearer #{profile_user.generate_jwt}" } }
        let(:'Authorization') { auth_headers['Authorization'] }
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

        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 email_address: { type: :string, format: :email },
                 address: { type: :string },
                 date_of_birth: { type: :string, format: 'date', nullable: true },
                 mobile_number: { type: :string, nullable: true },
                 latitude: { type: :number, format: :float, nullable: true },
                 longitude: { type: :number, format: :float, nullable: true },
                 onboarded: { type: :boolean },
                 created_at: { type: :string, format: 'date-time' },
                 updated_at: { type: :string, format: 'date-time' }
               },
               required: [ 'id', 'name', 'email_address', 'address', 'date_of_birth', 'mobile_number', 'onboarded' ]

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
          profile_user.reload
          expect(profile_user.onboarded).to eq(true)
        end
      end

      response(401, 'unauthorized') do
        let(:auth_user) { create(:user) }
        let(:user) { { user: { name: 'Updated Name' } } }
        let(:'Authorization') { 'Bearer invalid_token' }
        run_test!
      end

      response(422, 'invalid request') do
        let(:test_user) { create(:user) }
        let(:auth_headers) { { 'Authorization' => "Bearer #{test_user.generate_jwt}" } }
        let(:'Authorization') { auth_headers['Authorization'] }
        let(:user) { { user: { name: '' } } } # Empty name should fail validation

        run_test! do |response|
          expect(response.status).to eq(422)
          data = JSON.parse(response.body)
          expect(data['errors']).to include(/Name can't be blank/)
        end
      end
    end
  end
end
