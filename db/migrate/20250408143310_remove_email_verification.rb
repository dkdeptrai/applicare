class RemoveEmailVerification < ActiveRecord::Migration[8.0]
  def change
    # Remove email verification columns from users
    remove_column :users, :email_verified, :boolean
    remove_column :users, :email_verification_token, :string
    remove_column :users, :email_verification_sent_at, :datetime

    # Remove email verification columns from repairers
    remove_column :repairers, :email_verified, :boolean
    remove_column :repairers, :email_verification_token, :string
    remove_column :repairers, :email_verification_sent_at, :datetime
  end
end
