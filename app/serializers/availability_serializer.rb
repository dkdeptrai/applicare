class AvailabilitySerializer < ActiveModel::Serializer
  attributes :id, :day_of_week, :start_time, :end_time, :created_at, :updated_at
  belongs_to :repairer
end
