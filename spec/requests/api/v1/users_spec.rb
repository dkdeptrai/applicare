require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  let(:user) { User.create(email_address: 'jondoe@example.com', password_digest: BCrypt::Password.create('password')) }
  let(:token) { JwtToken.encode({ user_id: user.id }, exp: 7.days.from_now) }

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
                 password_digest: { type: :string }
               },
               required: %w[id email_address password_digest]

        let(:id) { user.id }
        let(:'Authorization') { "Bearer #{token}" }
        run_test!
      end

      response '404', 'user not found' do
        let(:id) { 'invalid' }
        let(:'Authorization') { "Bearer #{token}" }
        run_test!
      end
    end
  end
end
