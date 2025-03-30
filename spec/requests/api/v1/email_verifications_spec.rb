require 'swagger_helper'

RSpec.describe 'Email Verifications API', type: :request do
  path '/api/v1/verify_email' do
    post 'Verifies a user email using a token' do
      tags 'Email Verification'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :token_param, in: :body, schema: {
        type: :object,
        properties: {
          token: { type: :string }
        },
        required: [ 'token' ]
      }

      response '200', 'email verified successfully' do
        let(:user) { create(:user, :unverified) }
        let(:token_param) { { token: user.email_verification_token } }

        run_test! do |response|
          user.reload
          expect(user.email_verified).to be true
          expect(user.email_verification_token).to be_nil

          data = JSON.parse(response.body)
          expect(data['message']).to include('Email verified successfully')
        end
      end

      response '422', 'verification link expired' do
        let(:user) { create(:user, :unverified, email_verification_sent_at: 25.hours.ago) }
        let(:token_param) { { token: user.email_verification_token } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to include('Verification link expired')
        end
      end

      response '404', 'invalid verification token' do
        let(:token_param) { { token: 'invalid-token' } }
        run_test!
      end
    end
  end

  path '/api/v1/resend_verification' do
    post 'Resends verification email' do
      tags 'Email Verification'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :email_param, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string }
        },
        required: [ 'email' ]
      }

      response '200', 'verification email sent or account not found' do
        let(:user) { create(:user, :unverified) }
        let(:email_param) { { email: user.email_address } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to include('Verification email sent')
        end
      end

      response '200', 'verification email not sent - security through obscurity' do
        let(:email_param) { { email: 'nonexistent@example.com' } }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to include('If your account exists')
        end
      end
    end
  end
end
