class CreateRefreshTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :refresh_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.references :repairer, null: false, foreign_key: true
      t.string :token
      t.datetime :expires_at
      t.boolean :used

      t.timestamps
    end
  end
end
