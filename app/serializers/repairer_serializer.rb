class RepairerSerializer < ActiveModel::Serializer
  attributes :id, :email_address, :hourly_rate, :service_radius, :created_at, :updated_at
  has_many :services
end
