class AddUserToAppliance < ActiveRecord::Migration[8.0]
  def up
    add_reference :appliances, :user, null: true, foreign_key: true
    Appliance.reset_column_information
    Appliance.update_all(user_id: 1)
    change_column_null :appliances, :user_id, false
  end

  def down
    remove_reference :appliances, :user, foreign_key: true
  end
end
