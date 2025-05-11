class MakeRefreshTokenAssociationsOptional < ActiveRecord::Migration[7.1]
  def change
    change_column_null :refresh_tokens, :user_id, true
    change_column_null :refresh_tokens, :repairer_id, true
  end
end
