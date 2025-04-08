class CreateRepairers < ActiveRecord::Migration[8.0]
  def change
    create_table :repairers do |t|
      t.decimal :hourly_rate
      t.integer :service_radius

      t.timestamps
    end
  end
end
