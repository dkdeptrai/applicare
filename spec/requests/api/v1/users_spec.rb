require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  let(:verified_user) { create(:user, :verified) }
  let(:token) { JwtToken.encode({ user_id: verified_user.id }, exp: 7.days.from_now) }

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
                 email_address: { type: :string },
                 email_verified: { type: :boolean },
                 created_at: { type: :string, format: 'date-time' },
                 updated_at: { type: :string, format: 'date-time' }
               },
               required: %w[id email_address email_verified]

        let(:id) { verified_user.id }
        let(:'Authorization') { "Bearer #{token}" }
        run_test!
      end

      response '404', 'user not found' do
        let(:id) { 'invalid' }
        let(:'Authorization') { "Bearer #{token}" }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:id) { verified_user.id }
        let(:'Authorization') { "Bearer invalid_token" }

        run_test! do
          expect(response.status).to eq 401
          expect(response.body).to include("Unauthorized")
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
              email_address: { type: :string },
              password: { type: :string },
              password_confirmation: { type: :string }
            },
            required: %w[email_address password password_confirmation]
          }
        }
      }

      response '201', 'user created' do
        let(:user) { { user: { email_address: 'new@example.com', password: 'password123', password_confirmation: 'password123' } } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:user) { { user: { email_address: 'invalid', password: 'short', password_confirmation: 'mismatch' } } }
        run_test!
      end
    end
  end
end
