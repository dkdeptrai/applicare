class AddVerificationToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :email_verified, :boolean, default: false
    add_column :users, :email_verification_token, :string
    add_column :users, :email_verification_sent_at, :datetime
  end
end
