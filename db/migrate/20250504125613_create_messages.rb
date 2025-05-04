class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.references :booking, null: false, foreign_key: true
      t.text :content
      t.references :sender, polymorphic: true, null: false

      t.timestamps
    end
  end
end
