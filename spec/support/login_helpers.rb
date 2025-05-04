module LoginHelpers
  def login_as_user(user)
    # For JWT-based authentication in feature tests, we need to:
    # 1. Set up the JWT token
    # 2. Set up local storage with the token
    token = user.generate_jwt

    # Set the token in local storage
    page.execute_script("localStorage.setItem('jwt_token', '#{token}')")

    # You may also need to set up current_user in the test environment
    # to simulate a logged in user
    page.execute_script("window.currentUser = #{user.to_json}")
  end

  def login_as_repairer(repairer)
    # For JWT-based authentication in feature tests
    token = repairer.generate_jwt

    # Set the token in local storage
    page.execute_script("localStorage.setItem('jwt_token', '#{token}')")

    # You may also need to set up current_repairer in the test environment
    page.execute_script("window.currentRepairer = #{repairer.to_json}")
  end

  # Helper to make API calls with authentication
  def authenticated_request(method, path, user_or_repairer, params = {})
    token = user_or_repairer.generate_jwt

    headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{token}"
    }

    page.execute_script(<<~JS, method, path, headers, params)
      return fetch(arguments[1], {
        method: arguments[0],
        headers: arguments[2],
        body: arguments[0] !== 'GET' ? JSON.stringify(arguments[3]) : undefined
      }).then(r => r.json());
    JS
  end
end

RSpec.configure do |config|
  config.include LoginHelpers, type: :feature
end
