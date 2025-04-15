class AddOnboardingToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :onboarded, :boolean, default: false
    add_column :users, :date_of_birth, :date
    add_column :users, :mobile_number, :string
  end
end
