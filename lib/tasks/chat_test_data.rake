namespace :chat do
  desc "Load chat test data including appliances, services, bookings, and messages"
  task load_test_data: :environment do
    load Rails.root.join("db/seeds/chat_test_data.rb")
  end
end
