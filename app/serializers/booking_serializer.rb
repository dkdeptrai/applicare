class BookingSerializer < ActiveModel::Serializer
  attributes :id, :start_time, :end_time, :status, :address, :notes, :created_at, :updated_at, :repairer_id, :service_id
  belongs_to :repairer
  belongs_to :user
  belongs_to :service
end
