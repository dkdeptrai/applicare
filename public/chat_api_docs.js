/**
 * Applicare Chat Client
 *
 * This file demonstrates how to use the Applicare Chat API.
 * It is not meant to be imported directly, but rather serves as example code.
 */

/**
 * Connect to chat for a specific booking
 *
 * @param {number} bookingId - ID of the booking to connect to
 * @param {string} jwtToken - JWT authentication token
 * @param {function} onMessage - Callback when messages are received
 * @returns {Object} Chat client object
 */
function createChatClient(bookingId, jwtToken) {
  // Store messages locally
  let messages = [];

  // Define callbacks
  let callbacks = {
    onMessage: () => {},
    onConnect: () => {},
    onDisconnect: () => {},
    onError: () => {},
  };

  // Create WebSocket connection
  const socket = new WebSocket(
    `ws://${window.location.host}/cable?token=${jwtToken}`
  );

  socket.onopen = () => {
    // Subscribe to the chat channel
    socket.send(
      JSON.stringify({
        command: "subscribe",
        identifier: JSON.stringify({
          channel: "ChatChannel",
          booking_id: bookingId,
        }),
      })
    );

    callbacks.onConnect();
  };

  socket.onclose = () => {
    callbacks.onDisconnect();
  };

  socket.onerror = (error) => {
    callbacks.onError(error);
  };

  socket.onmessage = (event) => {
    const data = JSON.parse(event.data);

    // Ignore welcome and ping messages
    if (data.type === "welcome" || data.type === "ping") {
      return;
    }

    // Handle confirmation
    if (data.type === "confirm_subscription") {
      // Load message history through REST API
      fetch(`/api/v1/bookings/${bookingId}/messages`, {
        headers: {
          Authorization: `Bearer ${jwtToken}`,
          "Content-Type": "application/json",
        },
      })
        .then((response) => response.json())
        .then((data) => {
          messages = data;
          callbacks.onMessage(messages, null);
        });
      return;
    }

    // Handle new messages
    if (data.message) {
      messages.push(data.message);
      callbacks.onMessage(messages, data.message);
    }
  };

  // Chat client interface
  return {
    // Send a message
    sendMessage: (content) => {
      // Use the Action Cable channel for sending
      socket.send(
        JSON.stringify({
          command: "message",
          identifier: JSON.stringify({
            channel: "ChatChannel",
            booking_id: bookingId,
          }),
          data: JSON.stringify({
            content,
          }),
        })
      );

      // Alternatively, you can use the REST API
      /*
      fetch('/api/v1/messages', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${jwtToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          message: { content },
          booking_id: bookingId
        })
      });
      */
    },

    // Get all messages
    getMessages: () => {
      return [...messages];
    },

    // Set event handlers
    on: (event, callback) => {
      if (callbacks[`on${event.charAt(0).toUpperCase() + event.slice(1)}`]) {
        callbacks[`on${event.charAt(0).toUpperCase() + event.slice(1)}`] =
          callback;
      }
    },

    // Disconnect
    disconnect: () => {
      socket.close();
    },
  };
}

// Example usage:
/*
const chat = createChatClient(123, 'your_jwt_token');

// Set up event handlers
chat.on('connect', () => {
  console.log('Connected to chat!');
});

chat.on('message', (allMessages, newMessage) => {
  if (newMessage) {
    console.log('New message:', newMessage);
  } else {
    console.log('All messages:', allMessages);
  }
  
  // Update UI with messages...
});

chat.on('disconnect', () => {
  console.log('Disconnected from chat');
});

chat.on('error', (error) => {
  console.error('Chat error:', error);
});

// Send a message
chat.sendMessage('Hello, this is a test message!');

// When done
chat.disconnect();
*/
