require 'rails_helper'

RSpec.describe 'Chat functionality', type: :system, js: true do
  let(:user) { create(:user, email_address: 'test_user@example.com', password: 'password123') }
  let(:repairer) { create(:repairer, email_address: 'test_repairer@example.com', password: 'password123') }
  let(:appliance) { create(:appliance) }
  let(:service) { create(:service, repairer: repairer, appliance: appliance) }
  let(:booking) { create(:booking, user: user, repairer: repairer, service: service) }

  before do
    # Configure browser to allow ActionCable connections
    Capybara.server_host = '127.0.0.1'
    Capybara.server_port = '4000'
  end

  # This is a JavaScript test that simulates a chat session
  it 'allows sending and receiving chat messages via API' do
    skip "This test requires proper API setup in the test environment"

    # Visit any page to initialize the browser
    visit '/'

    # Login as the user
    login_as_user(user)

    # Create a test message via the API
    message_content = "Test message from API #{Time.now.to_i}"

    # Use our helper to make an authenticated API request
    authenticated_request('POST', '/api/v1/messages', user, {
      message: { content: message_content },
      booking_id: booking.id
    })

    # Check for the message using the API
    response = authenticated_request('GET', "/api/v1/bookings/#{booking.id}/messages", user)

    # Wait for the response and verify
    expect(page.evaluate_script('response')).to include(
      hash_including('content' => message_content)
    )
  end

  it 'allows sending and receiving chat messages via ActionCable' do
    skip "This test requires ActionCable running in the test environment"

    # Visit any page to initialize the browser
    visit '/'

    # Login as the user
    login_as_user(user)

    # Connect to ActionCable
    page.execute_script(<<~JS, booking.id, user.generate_jwt)
      window.testConsumer = ActionCable.createConsumer('/api/v1/cable?token=' + arguments[1]);
      window.testChannel = testConsumer.subscriptions.create(
        { channel: 'ChatChannel', booking_id: arguments[0] },
        {
          connected: function() {
            console.log('Connected to ChatChannel');
            window.channelConnected = true;
          },
          disconnected: function() {
            console.log('Disconnected from ChatChannel');
          },
          received: function(data) {
            console.log('Received message:', data);
            window.lastReceivedMessage = data;
          }
        }
      );
    JS

    # Wait for connection to be established
    Timeout.timeout(5) do
      loop do
        break if page.evaluate_script('window.channelConnected') == true
        sleep(0.1)
      end
    end

    # Should be connected now
    expect(page.evaluate_script('window.channelConnected')).to be true

    # Send a message through ActionCable
    cable_message = "Message via ActionCable #{Time.now.to_i}"
    page.execute_script(<<~JS, cable_message)
      window.testChannel.send({ content: arguments[0] });
    JS

    # Wait for message to be received
    Timeout.timeout(5) do
      loop do
        last_message = page.evaluate_script('window.lastReceivedMessage')
        break if last_message && last_message['content'] == cable_message
        sleep(0.1)
      end
    end

    # Verify message was received
    received_message = page.evaluate_script('window.lastReceivedMessage')
    expect(received_message['content']).to eq(cable_message)
    expect(received_message['booking_id']).to eq(booking.id)
  end
end
