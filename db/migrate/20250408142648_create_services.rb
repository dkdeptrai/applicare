class CreateServices < ActiveRecord::Migration[8.0]
  def change
    create_table :services do |t|
      t.string :name
      t.text :description
      t.integer :duration_minutes
      t.decimal :base_price
      t.references :repairer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
