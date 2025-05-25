require 'rails_helper'
require 'swagger_helper'

RSpec.describe Api::V1::AppliancesController, type: :request do
  include Rails.application.routes.url_helpers

  let!(:user) { create(:user, email_address: "test_user_#{rand(1000)}@example.com", password: 'password123') }
  let!(:repairer) { create(:repairer, email_address: "test_repairer_#{rand(1000)}@example.com", password: 'password123') }
  let!(:appliances) { create_list(:appliance, 3, user: user) }
  let!(:appliance) { appliances.first }
  let!(:service) { create(:service, repairer: repairer, appliance: appliance) }

  # Create first booking - start at 10 AM
  let(:start_time1) { 1.day.from_now.change(hour: 10) }
  let!(:booking1) { create(:booking, user: user, repairer: repairer, service: service, start_time: start_time1) }

  # Create second booking - start at 2 PM
  let(:start_time2) { 1.day.from_now.change(hour: 14) }
  let!(:booking2) { create(:booking, user: user, repairer: repairer, service: service, start_time: start_time2) }

  let(:headers) { { 'Authorization' => "Bearer #{user.generate_jwt}" } }
  let(:repairer_headers) { { 'Authorization' => "Bearer #{repairer.generate_jwt}" } }

  path '/api/v1/appliances' do
    get 'Retrieves all appliances' do
      tags 'Appliances'
      produces 'application/json'

      response '200', 'appliances found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   brand: { type: :string },
                   model: { type: :string },
                   image_url: { type: :string, nullable: true },
                   created_at: { type: :string, format: 'date-time' },
                   updated_at: { type: :string, format: 'date-time' }
                 },
                 required: %w[id name brand model]
               }

        run_test!
      end
    end

    post 'Creates an appliance' do
      tags 'Appliances'
      consumes 'multipart/form-data'
      produces 'application/json'
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'
      parameter name: 'appliance[name]', in: :formData, type: :string, required: true
      parameter name: 'appliance[brand]', in: :formData, type: :string, required: true
      parameter name: 'appliance[model]', in: :formData, type: :string, required: true
      parameter name: 'image', in: :formData, type: :file, required: false, description: 'Appliance image'

      response '201', 'appliance created' do
        let(:'Authorization') { headers['Authorization'] }
        let(:'appliance[name]') { 'New Appliance' }
        let(:'appliance[brand]') { 'Test Brand' }
        let(:'appliance[model]') { 'Test Model' }
        let(:image) { Rack::Test::UploadedFile.new(StringIO.new("dummy image content"), 'image/jpeg', original_filename: 'test_image.jpg') }

        before do
          skip "Skipping test with Cloudinary interactions"
          allow(Cloudinary::Uploader).to receive(:upload).and_return({ 'secure_url' => 'https://res.cloudinary.com/test-cloud/image/upload/appliances/test_image.jpg' })
        end

        run_test! do |response|
          expect(response.status).to eq(201)
        end
      end

      response '422', 'invalid request' do
        let(:'Authorization') { headers['Authorization'] }
        let(:'appliance[name]') { nil }
        let(:'appliance[brand]') { nil }
        let(:'appliance[model]') { nil }
        let(:image) { nil }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:'Authorization') { 'Bearer invalid_token' }
        let(:'appliance[name]') { 'New Appliance' }
        let(:'appliance[brand]') { 'Test Brand' }
        let(:'appliance[model]') { 'Test Model' }
        let(:image) { nil }
        run_test!
      end

      response '500', 'Cloudinary upload error' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }
        let(:'Authorization') { headers['Authorization'] }
        let(:'appliance[name]') { 'New Appliance' }
        let(:'appliance[brand]') { 'Test Brand' }
        let(:'appliance[model]') { 'Test Model' }
        let(:image) { Rack::Test::UploadedFile.new(StringIO.new("dummy image content"), 'image/jpeg', original_filename: 'test_image.jpg') }

        before do
          skip "Skipping test for Cloudinary error handling"
          allow(Cloudinary::Uploader).to receive(:upload).and_raise(Cloudinary::CloudinaryException, "Upload failed")
        end

        run_test! do |response|
          expect(response.status).to eq(500)
        end
      end
    end
  end

  path '/api/v1/appliances/my_appliances' do
    get 'Retrieves appliances owned by the current user' do
      tags 'Appliances'
      produces 'application/json'
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'

      response '200', 'user appliances found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   brand: { type: :string },
                   model: { type: :string },
                   image_url: { type: :string, nullable: true },
                   created_at: { type: :string, format: 'date-time' },
                   updated_at: { type: :string, format: 'date-time' }
                 },
                 required: %w[id name brand model]
               }

        let(:'Authorization') { headers['Authorization'] }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:'Authorization') { 'Bearer invalid_token' }
        run_test!
      end
    end
  end

  path '/api/v1/appliances/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'ID of the appliance'

    get 'Retrieves an appliance' do
      tags 'Appliances'
      produces 'application/json'

      response '200', 'appliance found' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 brand: { type: :string },
                 model: { type: :string },
                 image_url: { type: :string, nullable: true },
                 created_at: { type: :string, format: 'date-time' },
                 updated_at: { type: :string, format: 'date-time' }
               },
               required: %w[id name brand model]

        let(:id) { appliance.id }
        run_test!
      end

      response '404', 'appliance not found' do
        let(:id) { 999 }
        run_test!
      end
    end

    put 'Updates an appliance' do
      tags 'Appliances'
      consumes 'multipart/form-data'
      produces 'application/json'
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'
      parameter name: :id, in: :path, type: :integer
      parameter name: 'appliance[name]', in: :formData, type: :string, required: false
      parameter name: 'appliance[brand]', in: :formData, type: :string, required: false
      parameter name: 'appliance[model]', in: :formData, type: :string, required: false
      parameter name: 'image', in: :formData, type: :file, required: false, description: 'Appliance image'

      response '200', 'appliance updated' do
        let(:id) { appliance.id }
        let(:'Authorization') { headers['Authorization'] }
        let(:'appliance[name]') { 'Updated Appliance' }
        let(:'appliance[brand]') { 'Updated Brand' }
        let(:'appliance[model]') { 'Updated Model' }
        let(:image) { Rack::Test::UploadedFile.new(StringIO.new("dummy image content"), 'image/jpeg', original_filename: 'test_image.jpg') }

        before do
          skip "Skipping test with Cloudinary interactions"
          allow(Cloudinary::Uploader).to receive(:upload).and_return({ 'secure_url' => 'https://res.cloudinary.com/test-cloud/image/upload/appliances/updated_image.jpg' })
        end

        run_test! do |response|
          expect(response.status).to eq(200)
        end
      end

      response '422', 'invalid request' do
        let(:id) { appliance.id }
        let(:'Authorization') { headers['Authorization'] }
        let(:'appliance[name]') { nil }
        let(:'appliance[brand]') { nil }
        let(:'appliance[model]') { nil }
        let(:image) { nil }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:id) { appliance.id }
        let(:'Authorization') { 'Bearer invalid_token' }
        let(:'appliance[name]') { 'Updated Appliance' }
        let(:image) { nil }
        run_test!
      end

      response '500', 'Cloudinary upload error' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }
        let(:id) { appliance.id }
        let(:'Authorization') { headers['Authorization'] }
        let(:'appliance[name]') { 'Updated Appliance' }
        let(:image) { Rack::Test::UploadedFile.new(StringIO.new("dummy image content"), 'image/jpeg', original_filename: 'test_image.jpg') }

        before do
          skip "Skipping test for Cloudinary error handling"
          allow(Cloudinary::Uploader).to receive(:upload).and_raise(Cloudinary::CloudinaryException, "Upload failed")
        end

        run_test! do |response|
          expect(response.status).to eq(500)
        end
      end
    end

    delete 'Deletes an appliance' do
      tags 'Appliances'
      produces 'application/json'
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'

      response '204', 'appliance deleted' do
        let(:id) { appliance.id }
        let(:'Authorization') { headers['Authorization'] }
        run_test!
      end

      response '404', 'appliance not found' do
        let(:id) { 999 }
        let(:'Authorization') { headers['Authorization'] }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:id) { appliance.id }
        let(:'Authorization') { 'Bearer invalid_token' }
        run_test!
      end
    end
  end

  path '/api/v1/appliances/{id}/bookings' do
    parameter name: :id, in: :path, type: :integer, description: 'ID of the appliance'

    get 'Retrieves all bookings for an appliance belonging to the current user' do
      tags 'Appliances'
      produces 'application/json'
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'

      response '200', 'bookings found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   repairer_id: { type: :integer },
                   service_id: { type: :integer },
                   start_time: { type: :string, format: 'date-time' },
                   end_time: { type: :string, format: 'date-time' },
                   status: { type: :string },
                   address: { type: :string },
                   notes: { type: :string, nullable: true },
                   created_at: { type: :string, format: 'date-time' },
                   updated_at: { type: :string, format: 'date-time' }
                 },
                 required: %w[id repairer_id service_id start_time end_time status address]
               }

        let(:id) { appliance.id }
        let(:'Authorization') { headers['Authorization'] }
        run_test!
      end

      response '404', 'appliance not found' do
        let(:id) { 999 }
        let(:'Authorization') { headers['Authorization'] }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:id) { appliance.id }
        let(:'Authorization') { 'Bearer invalid_token' }
        run_test!
      end
    end
  end

  path '/api/v1/appliances/{id}/repair_history' do
    parameter name: :id, in: :path, type: :integer, description: 'ID of the appliance'
    parameter name: :status, in: :query, type: :string, required: false, description: 'Filter by booking status'

    get 'Fetches the full repair history for an appliance (owner only)' do
      tags 'Appliances'
      produces 'application/json'
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'

      response '200', 'repair history found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   repairer_id: { type: :integer },
                   user_id: { type: :integer },
                   service_id: { type: :integer },
                   start_time: { type: :string, format: 'date-time' },
                   end_time: { type: :string, format: 'date-time' },
                   status: { type: :string },
                   address: { type: :string },
                   notes: { type: :string, nullable: true },
                   repairer_note: { type: :string, nullable: true },
                   created_at: { type: :string, format: 'date-time' },
                   updated_at: { type: :string, format: 'date-time' }
                 },
                 required: %w[id repairer_id user_id service_id start_time end_time status address]
               }
        let(:id) { appliance.id }
        let(:'Authorization') { headers['Authorization'] }
        run_test! do |response|
          expect(response.status).to eq(200)
          json = JSON.parse(response.body)
          expect(json).to be_an(Array)
          expect(json.map { |b| b['id'] }).to include(booking1.id, booking2.id)
        end
      end

      response '200', 'repair history filtered by status' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   status: { type: :string }
                 },
                 required: %w[id status]
               }
        let(:id) { appliance.id }
        let(:'Authorization') { headers['Authorization'] }
        let(:status) { booking1.status }
        run_test! do |response|
          expect(response.status).to eq(200)
          json = JSON.parse(response.body)
          expect(json).to all(include('status' => booking1.status))
        end
      end

      response '403', 'not authorized' do
        let(:id) { appliance.id }
        let(:'Authorization') { repairer_headers['Authorization'] }
        run_test! do |response|
          expect(response.status).to eq(403)
        end
      end

      response '404', 'appliance not found' do
        let(:id) { 999_999 }
        let(:'Authorization') { headers['Authorization'] }
        run_test! do |response|
          expect(response.status).to eq(404)
        end
      end
    end
  end
end
