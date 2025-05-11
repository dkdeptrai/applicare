require 'swagger_helper'

RSpec.describe 'Repairer Sessions API', type: :request do
  path '/api/v1/repairer_sessions' do
    post 'Creates a repairer session (logs in)' do
      tags 'Repairer Authentication'
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

      response '201', 'repairer logged in' do
        let(:repairer) { create(:repairer, password: 'password123') }
        let(:login_params) { { email_address: repairer.email_address, password: 'password123' } }

        schema type: :object,
               properties: {
                 access_token: { type: :string },
                 refresh_token: { type: :string },
                 token_type: { type: :string },
                 expires_in: { type: :integer },
                 repairer: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string },
                     email_address: { type: :string }
                   }
                 }
               },
               required: %w[access_token refresh_token token_type expires_in repairer]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['access_token']).to be_present
          expect(data['refresh_token']).to be_present
          expect(data['token_type']).to eq('Bearer')
          expect(data['expires_in']).to be_present
          expect(data['repairer']).to be_present
        end
      end

      response '401', 'unauthorized - invalid credentials' do
        let(:login_params) { { email_address: 'wrong@example.com', password: 'wrongpassword' } }
        run_test!
      end
    end
  end

  path '/api/v1/repairer_sessions/{id}' do
    delete 'Destroys a repairer session (logs out)' do
      tags 'Repairer Authentication'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string, description: 'ID is optional'
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'

      response '200', 'repairer logged out' do
        let(:repairer) { create(:repairer) }
        let(:token) { JwtToken.encode({ repairer_id: repairer.id }, exp: 7.days.from_now) }
        let(:id) { 'current' }
        let(:'Authorization') { "Bearer #{token}" }

        before do
          allow_any_instance_of(Api::V1::RepairerSessionsController).to receive(:current_repairer).and_return(repairer)
        end

        run_test!
      end

      response '401', 'unauthorized' do
        let(:id) { 'current' }
        let(:'Authorization') { "Bearer invalid_token" }

        run_test!
      end
    end
  end
end
