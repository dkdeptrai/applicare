require 'rails_helper'
require 'swagger_helper'

RSpec.describe Api::V1::AppliancesController, type: :request do
  include Rails.application.routes.url_helpers

  let!(:user) { create(:user, email_address: "test_user_#{rand(1000)}@example.com", password: 'password123') }
  let!(:repairer) { create(:repairer, email_address: "test_repairer_#{rand(1000)}@example.com", password: 'password123') }
  let!(:appliances) { create_list(:appliance, 3) }
  let!(:appliance) { appliances.first }
  let(:headers) { { 'Authorization' => "Bearer #{repairer.generate_jwt}" } }

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
      consumes 'application/json'
      produces 'application/json'
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'
      parameter name: :appliance_params, in: :body, schema: {
        type: :object,
        properties: {
          appliance: {
            type: :object,
            properties: {
              name: { type: :string },
              brand: { type: :string },
              model: { type: :string }
            },
            required: %w[name brand model]
          }
        }
      }

      response '201', 'appliance created' do
        let(:'Authorization') { headers['Authorization'] }
        let(:appliance_params) { { appliance: { name: 'New Appliance', brand: 'Test Brand', model: 'Test Model' } } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:'Authorization') { headers['Authorization'] }
        let(:appliance_params) { { appliance: { name: nil, brand: nil, model: nil } } }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:'Authorization') { 'Bearer invalid_token' }
        let(:appliance_params) { { appliance: { name: 'New Appliance', brand: 'Test Brand', model: 'Test Model' } } }
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
      consumes 'application/json'
      produces 'application/json'
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'JWT token'
      parameter name: :appliance_params, in: :body, schema: {
        type: :object,
        properties: {
          appliance: {
            type: :object,
            properties: {
              name: { type: :string },
              brand: { type: :string },
              model: { type: :string }
            }
          }
        }
      }

      response '200', 'appliance updated' do
        let(:id) { appliance.id }
        let(:'Authorization') { headers['Authorization'] }
        let(:appliance_params) { { appliance: { name: 'Updated Appliance', brand: 'Updated Brand', model: 'Updated Model' } } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:id) { appliance.id }
        let(:'Authorization') { headers['Authorization'] }
        let(:appliance_params) { { appliance: { name: nil, brand: nil, model: nil } } }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:id) { appliance.id }
        let(:'Authorization') { 'Bearer invalid_token' }
        let(:appliance_params) { { appliance: { name: 'Updated Appliance' } } }
        run_test!
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
end
