require 'rails_helper'
require 'swagger_helper'

RSpec.describe Api::MessagesController, type: :request do
  include Rails.application.routes.url_helpers

  # Test data setup
  let!(:user) { create(:user, email_address: "chat_user_#{rand(1000)}@example.com", password: 'password123') }
  let!(:repairer) { create(:repairer, email_address: "chat_repairer_#{rand(1000)}@example.com", password: 'password123') }
  let!(:service) { create(:service, repairer: repairer) }
  let!(:booking) { create(:booking, user: user, repairer: repairer, service: service) }
  let!(:messages) { create_list(:message, 3, booking: booking, sender: user) }
  let(:user_headers) { { 'Authorization' => "Bearer #{user.generate_jwt}" } }
  let(:repairer_headers) { { 'Authorization' => "Bearer #{repairer.generate_jwt}" } }

  path '/api/bookings/{booking_id}/messages' do
    parameter name: :booking_id, in: :path, type: :integer, description: 'ID of the booking'

    get 'Retrieves all messages for a booking' do
      tags 'Chat'
      produces 'application/json'
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'

      response '200', 'messages found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   content: { type: :string },
                   created_at: { type: :string, format: 'date-time' },
                   sender_type: { type: :string },
                   sender_id: { type: :integer },
                   sender_info: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string },
                       type: { type: :string }
                     }
                   }
                 },
                 required: %w[id content created_at sender_type sender_id]
               }

        let(:booking_id) { booking.id }
        let(:'Authorization') { user_headers['Authorization'] }
        run_test!
      end

      response '404', 'booking not found' do
        let(:booking_id) { 999 }
        let(:'Authorization') { user_headers['Authorization'] }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:booking_id) { booking.id }
        let(:'Authorization') { 'Bearer invalid_token' }
        run_test!
      end

      response '403', 'forbidden (not user or repairer of booking)' do
        let!(:other_user) { create(:user, email_address: "other_user_#{rand(1000)}@example.com", password: 'password123') }
        let(:other_user_headers) { { 'Authorization' => "Bearer #{other_user.generate_jwt}" } }
        let(:booking_id) { booking.id }
        let(:'Authorization') { other_user_headers['Authorization'] }
        run_test!
      end
    end
  end

  path '/api/messages' do
    post 'Creates a new message' do
      tags 'Chat'
      consumes 'application/json'
      produces 'application/json'
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'
      parameter name: :message_params, in: :body, schema: {
        type: :object,
        properties: {
          message: {
            type: :object,
            properties: {
              content: { type: :string }
            },
            required: %w[content]
          },
          booking_id: { type: :integer }
        },
        required: %w[message booking_id]
      }

      response '201', 'message created' do
        let(:'Authorization') { user_headers['Authorization'] }
        let(:message_params) { { message: { content: 'Hello! This is a test message' }, booking_id: booking.id } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:'Authorization') { user_headers['Authorization'] }
        let(:message_params) { { message: { content: '' }, booking_id: booking.id } }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:'Authorization') { 'Bearer invalid_token' }
        let(:message_params) { { message: { content: 'Test message' }, booking_id: booking.id } }
        run_test!
      end

      response '404', 'booking not found' do
        let(:'Authorization') { user_headers['Authorization'] }
        let(:message_params) { { message: { content: 'Test message' }, booking_id: 999 } }
        run_test!
      end

      response '403', 'forbidden (not user or repairer of booking)' do
        let!(:other_user) { create(:user, email_address: "other_post_user_#{rand(1000)}@example.com", password: 'password123') }
        let(:other_user_headers) { { 'Authorization' => "Bearer #{other_user.generate_jwt}" } }
        let(:'Authorization') { other_user_headers['Authorization'] }
        let(:message_params) { { message: { content: 'Test message' }, booking_id: booking.id } }
        run_test!
      end
    end
  end

  # WebSocket documentation note
  # The WebSocket chat functionality is documented in swagger/v1/chat_protocol.yaml
  # and in the main API description in swagger/v1/swagger.yaml
end
