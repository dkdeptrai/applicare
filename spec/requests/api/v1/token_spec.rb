require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Api::V1::TokenController", type: :request do
  describe "POST /api/v1/token/refresh" do
    # Skip JWT authentication for testing
    before do
      allow_any_instance_of(Api::V1::TokenController).to receive(:authenticate_request).and_return(true)
    end

    path '/api/v1/token/refresh' do
      post 'Refresh access token' do
        tags 'Authentication'
        consumes 'application/json'
        produces 'application/json'
        parameter name: :refresh_token_params, in: :body, schema: {
          type: :object,
          properties: {
            refresh_token: { type: :string }
          },
          required: %w[refresh_token]
        }

        let(:user) { create(:user) }
        let(:refresh_token) { create(:refresh_token, :for_user, user: user) }

        response '200', 'token refreshed successfully' do
          let(:refresh_token_params) { { refresh_token: refresh_token.token } }

          schema type: :object,
                 properties: {
                   access_token: { type: :string },
                   refresh_token: { type: :string },
                   token_type: { type: :string },
                   expires_in: { type: :integer }
                 },
                 required: %w[access_token refresh_token token_type expires_in]

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['access_token']).to be_present
            expect(data['refresh_token']).to be_present
            expect(data['token_type']).to eq('Bearer')
            expect(data['expires_in']).to be_present
          end
        end

        response '400', 'bad request - refresh token not provided' do
          let(:refresh_token_params) { {} }

          schema type: :object,
                 properties: {
                   error: { type: :string }
                 },
                 required: %w[error]

          run_test!
        end

        response '401', 'unauthorized - invalid refresh token' do
          let(:refresh_token_params) { { refresh_token: 'invalid_token' } }

          schema type: :object,
                 properties: {
                   error: { type: :string }
                 },
                 required: %w[error]

          run_test!
        end
      end
    end
  end
end
