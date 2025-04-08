require 'swagger_helper'

RSpec.describe 'Sessions API', type: :request do
  path '/api/v1/sessions' do
    post 'Creates a session (logs in)' do
      tags 'Sessions'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :login_params, in: :body, schema: {
        type: :object,
        properties: {
          email_address: { type: :string },
          password: { type: :string }
        },
        required: %w[email_address password]
      }

      response '200', 'user logged in' do
        let(:user) { create(:user, password: 'password123') }
        let(:login_params) { { email_address: user.email_address, password: 'password123' } }

        schema type: :object,
               properties: {
                 token: { type: :string },
                 user_id: { type: :integer }
               },
               required: %w[token user_id]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['token']).to be_present
          expect(data['user_id']).to eq(user.id)
        end
      end

      response '401', 'unauthorized - invalid credentials' do
        let(:login_params) { { email_address: 'wrong@example.com', password: 'wrongpassword' } }
        run_test!
      end
    end
  end

  path '/api/v1/sessions/{id}' do
    delete 'Destroys a session (logs out)' do
      tags 'Sessions'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string, description: 'ID is optional'
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'

      response '200', 'user logged out' do
        let(:user) { create(:user) }
        let(:token) { JwtToken.encode({ user_id: user.id }, exp: 7.days.from_now) }
        let(:id) { 'current' }
        let(:'Authorization') { "Bearer #{token}" }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:id) { 'current' }
        let(:'Authorization') { "Bearer invalid_token" }

        run_test! do
          expect(response.status).to eq 401
          expect(response.body).to include("Unauthorized")
        end
      end
    end
  end
end
