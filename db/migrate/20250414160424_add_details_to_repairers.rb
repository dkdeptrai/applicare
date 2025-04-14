class AddDetailsToRepairers < ActiveRecord::Migration[8.0]
  def change
    add_column :repairers, :professional, :boolean
    add_column :repairers, :years_experience, :integer
    add_column :repairers, :ratings_average, :float
    add_column :repairers, :reviews_count, :integer
    add_column :repairers, :clients_count, :integer
    add_column :repairers, :bio, :text
    add_column :repairers, :profile_picture_id, :string
    add_column :repairers, :work_image_ids, :jsonb, default: [], null: false
  end
end
