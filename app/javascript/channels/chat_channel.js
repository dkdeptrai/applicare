import consumer from "./consumer";

/**
 * Connect to a chat channel for a specific booking
 *
 * @param {number} bookingId - The ID of the booking to connect to
 * @param {string} authToken - JWT token for authentication
 * @param {function} onReceived - Callback when a message is received
 * @param {function} onConnected - Callback when connection is established
 * @param {function} onDisconnected - Callback when disconnected
 * @param {function} onRejected - Callback when connection is rejected
 * @returns {object} The subscription object that can be used to send messages
 */
export const connectToChatChannel = (
  bookingId,
  authToken,
  onReceived,
  onConnected = () => {},
  onDisconnected = () => {},
  onRejected = () => {}
) => {
  return consumer.subscriptions.create(
    {
      channel: "ChatChannel",
      booking_id: bookingId,
      token: authToken,
    },
    {
      connected() {
        onConnected();
      },

      disconnected() {
        onDisconnected();
      },

      rejected() {
        onRejected();
      },

      received(data) {
        onReceived(data);
      },

      send(content) {
        this.perform("receive", { content });
      },
    }
  );
};
