class AddRepairerAttributesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :hourly_rate, :decimal, precision: 10, scale: 2
    add_column :users, :service_radius, :integer
  end
end
