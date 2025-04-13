class RepairerSerializer < ActiveModel::Serializer
  attributes :id, :name, :email_address, :hourly_rate, :service_radius, :latitude, :longitude, :created_at, :updated_at
  has_many :services

  def hourly_rate
    object.hourly_rate.to_f
  end
end
