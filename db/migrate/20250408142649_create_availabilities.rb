class CreateAvailabilities < ActiveRecord::Migration[8.0]
  def change
    create_table :availabilities do |t|
      t.time :start_time
      t.time :end_time
      t.integer :day_of_week
      t.references :repairer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
