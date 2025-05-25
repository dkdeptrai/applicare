# == Schema Information
#
# Table name: appliances
#
#  id         :bigint           not null, primary key
#  brand      :string           not null
#  image_url  :string
#  model      :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_appliances_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class ApplianceSerializer < ActiveModel::Serializer
  attributes :id, :name, :brand, :model, :image_url, :created_at, :updated_at, :user_id
end
