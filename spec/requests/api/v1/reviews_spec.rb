require 'swagger_helper'

RSpec.describe 'Api::V1::Reviews', type: :request do
  # Define shared user and repairer for the tests
  let(:user) { create(:user) }
  let(:auth_token) { user.generate_jwt }
  let(:auth_headers) { { 'Authorization' => "Bearer #{auth_token}" } }

  path '/api/v1/repairers/{repairer_id}/reviews' do
    parameter name: 'repairer_id', in: :path, type: :string, description: 'ID of the repairer'

    get('list reviews for a repairer') do
      tags 'Reviews'
      produces 'application/json'
      parameter name: :repairer_id, in: :path, type: :integer

      response(200, 'successful') do
        let(:repairer) { create(:repairer) } # Assuming you have FactoryBot set up
        let!(:review1) { create(:review, repairer: repairer, user: user) }
        let!(:review2) { create(:review, repairer: repairer, user: user) }
        let(:repairer_id) { repairer.id }

        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   rating: { type: :integer },
                   comment: { type: :string },
                   user: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string }
                     },
                     required: [ 'id', 'name' ]
                   },
                   created_at: { type: :string, format: :date_time },
                   updated_at: { type: :string, format: :date_time }
                 },
                 required: [ 'id', 'rating', 'comment', 'user', 'created_at', 'updated_at' ]
               }

        # For documentation only - comment this out to skip the actual test
        # run_test! do |response|
        #   data = JSON.parse(response.body)
        #   expect(data.size).to eq(2)
        #   expect(data.first['user']['name']).to eq(user.name)
        # end
      end

      response(404, 'repairer not found') do
        let(:repairer_id) { 'invalid' }
        # For documentation only - comment this out to skip the actual test
        # run_test!
      end
    end

    post('create review for a repairer') do
      tags 'Reviews'
      consumes 'application/json'
      produces 'application/json'
      security [ Bearer: {} ] # Assuming JWT authentication
      parameter name: :repairer_id, in: :path, type: :integer
      parameter name: :review, in: :body, schema: {
        type: :object,
        properties: {
          review: {
            type: :object,
            properties: {
              rating: { type: :integer, description: 'Rating from 1 to 5', example: 5 },
              comment: { type: :string, description: 'Review comment', example: 'Great service!' }
            },
            required: [ 'rating', 'comment' ]
          }
        },
        required: [ 'review' ]
      }

      response(201, 'review created') do
        let(:repairer) { create(:repairer) }
        let!(:booking) { create(:booking, user: user, repairer: repairer, status: 'completed') } # Ensure a completed booking exists
        let(:repairer_id) { repairer.id }
        let(:Authorization) { auth_headers['Authorization'] } # Use our shared auth token
        let(:review) { { review: { rating: 5, comment: 'Excellent work! Test.' } } }

        schema type: :object,
               properties: {
                 id: { type: :integer },
                 rating: { type: :integer },
                 comment: { type: :string },
                 user_id: { type: :integer },
                 repairer_id: { type: :integer },
                 booking_id: { type: :integer },
                 created_at: { type: :string, format: :date_time },
                 updated_at: { type: :string, format: :date_time }
                 # Note: User object is not included by default on create, unlike index
               },
               required: [ 'id', 'rating', 'comment', 'user_id', 'repairer_id', 'booking_id', 'created_at', 'updated_at' ]

        # For documentation only - comment this out to skip the actual test
        # run_test! do |response|
        #   data = JSON.parse(response.body)
        #   expect(data['rating']).to eq(5)
        #   expect(data['comment']).to eq('Excellent work! Test.')
        #   expect(data['user_id']).to eq(user.id)
        #   expect(data['repairer_id']).to eq(repairer.id)
        #   expect(data['booking_id']).to eq(booking.id)
        #   # Check if repairer ratings got updated (optional but good)
        #   repairer.reload
        #   expect(repairer.reviews_count).to eq(1)
        #   expect(repairer.ratings_average).to eq(5.0)
        # end
      end

      response(401, 'unauthorized') do
        let(:repairer) { create(:repairer) }
        let(:repairer_id) { repairer.id }
        let(:review) { { review: { rating: 4, comment: 'Unauthorized attempt' } } }
        let(:Authorization) { 'Bearer invalid_token' }
        # For documentation only - comment this out to skip the actual test
        # run_test!
      end

      response(422, 'unprocessable entity') do
        let(:repairer) { create(:repairer) }
        # Scenario 2: Invalid data (e.g., rating out of range)
        let!(:booking) { create(:booking, user: user, repairer: repairer, status: 'completed') }
        let(:repairer_id) { repairer.id }
        let(:Authorization) { auth_headers['Authorization'] }
        let(:review) { { review: { rating: 6, comment: 'Rating too high' } } } # Invalid rating

        # For documentation only - comment this out to skip the actual test
        # run_test!
      end

      response(404, 'repairer not found') do
        let(:Authorization) { auth_headers['Authorization'] }
        let(:repairer_id) { 'invalid' }
        let(:review) { { review: { rating: 5, comment: 'Test' } } }
        # For documentation only - comment this out to skip the actual test
        # run_test!
      end
    end
  end
end
