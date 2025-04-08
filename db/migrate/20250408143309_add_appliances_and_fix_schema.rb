class AddAppliancesAndFixSchema < ActiveRecord::Migration[8.0]
  def change
    # Create appliances table
    create_table :appliances do |t|
      t.string :name, null: false
      t.string :brand, null: false
      t.string :model, null: false
      t.timestamps
    end

    # Add appliance_id to services
    add_reference :services, :appliance, null: false, foreign_key: true

    # Remove redundant columns from users
    remove_column :users, :hourly_rate, :decimal
    remove_column :users, :service_radius, :integer

    # Add missing columns to repairers
    add_column :repairers, :name, :string, null: false
    add_column :repairers, :email_address, :string, null: false
    add_column :repairers, :password_digest, :string, null: false
    add_column :repairers, :email_verified, :boolean, default: false
    add_column :repairers, :email_verification_token, :string
    add_column :repairers, :email_verification_sent_at, :datetime

    # Add missing columns to users
    add_column :users, :name, :string, null: false

    # Add indexes
    add_index :repairers, :email_address, unique: true
  end
end
