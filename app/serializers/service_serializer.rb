class ServiceSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :duration_minutes, :base_price, :created_at, :updated_at
  belongs_to :repairer
end
