class AddLocationToUsersAndRepairers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :latitude, :float
    add_column :users, :longitude, :float
    add_column :repairers, :latitude, :float
    add_column :repairers, :longitude, :float
  end
end
