class AddAddressToUsersAndRepairers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :address, :string, default: ''
    add_column :repairers, :address, :string, default: ''
  end
end
