module RequestSpecHelper
  # Parse JSON response to a hash
  def json_response
    JSON.parse(response.body)
  end

  # Generate auth headers for a user
  def auth_headers_for(user)
    token = generate_user_jwt(user)
    {
      'Authorization' => "Bearer #{token}",
      'Content-Type' => 'application/json'
    }
  end

  # Generate auth headers for a repairer
  def auth_headers_for_repairer(repairer)
    token = generate_repairer_jwt(repairer)
    {
      'Authorization' => "Bearer #{token}",
      'Content-Type' => 'application/json'
    }
  end
end

RSpec.configure do |config|
  config.include RequestSpecHelper, type: :request
end
