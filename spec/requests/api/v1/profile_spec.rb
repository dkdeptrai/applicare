require 'swagger_helper'

RSpec.describe 'Profile API', type: :request do
  path '/api/v1/profile' do
    get('Retrieves the current user profile') do
      tags 'Profile'
      produces 'application/json'
      security [ Bearer: [] ]
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'

      response(200, 'successful') do
        let(:user) { create(:user, name: 'Test User', email_address: 'profile@test.com') } # Create a specific user
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
                 created_at: { type: :string, format: 'date-time' },
                 updated_at: { type: :string, format: 'date-time' }
               },
               required: [ 'id', 'name', 'email_address', 'address', 'created_at', 'updated_at' ]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(user.id)
          expect(data['name']).to eq('Test User')
          expect(data['email_address']).to eq('profile@test.com')
          expect(data['address']).to eq('') # Default address
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
  end
end
