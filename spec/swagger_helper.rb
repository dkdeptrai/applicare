# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      servers: [
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'www.example.com'
            }
          }
        }
      ],
      components: {
        schemas: {
          error: {
            type: :object,
            properties: {
              error: { type: :string, description: "Error message" }
            },
            required: [ 'error' ]
          },
          repairer: {
            type: :object,
            properties: {
              id: { type: :integer, description: 'Repairer ID' },
              name: { type: :string, description: 'Repairer name' },
              email_address: { type: :string, format: :email, description: 'Repairer email' },
              hourly_rate: { type: :number, format: :float, description: 'Hourly rate' },
              service_radius: { type: :integer, description: 'Service radius in km' },
              latitude: { type: :number, format: :float, description: 'Latitude' },
              longitude: { type: :number, format: :float, description: 'Longitude' }
              # Add other relevant attributes exposed by your RepairerSerializer
            },
            required: [ 'id', 'name', 'email_address' ] # Adjust required fields as needed
          },
          booking: {
            type: :object,
            properties: {
              id: { type: :integer, description: 'Booking ID' },
              repairer_id: { type: :integer, description: 'Repairer ID' },
              user_id: { type: :integer, description: 'User ID' },
              service_id: { type: :integer, description: 'Service ID' },
              start_time: { type: :string, format: 'date-time', description: 'Start time of booking' },
              end_time: { type: :string, format: 'date-time', description: 'End time of booking' },
              status: {
                type: :string,
                enum: [ 'pending', 'confirmed', 'completed', 'cancelled' ],
                description: 'Booking status'
              },
              address: { type: :string, description: 'Service address' },
              notes: { type: :string, nullable: true, description: 'Customer notes' },
              repairer_note: { type: :string, nullable: true, description: 'Repairer notes' },
              created_at: { type: :string, format: 'date-time', description: 'Creation timestamp' },
              updated_at: { type: :string, format: 'date-time', description: 'Last update timestamp' }
            },
            required: %w[id repairer_id user_id service_id start_time end_time status address]
          }
        },
        securitySchemes: {
          Bearer: {
            type: :http,
            scheme: :bearer,
            description: 'JWT token for authentication'
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
