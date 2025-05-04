# == Schema Information
#
# Table name: appliances
#
#  id         :bigint           not null, primary key
#  brand      :string           not null
#  model      :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ApplianceSerializer < ActiveModel::Serializer
  attributes :id, :name, :brand, :model, :created_at, :updated_at
end
