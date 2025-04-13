class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email_address, :address, :latitude, :longitude, :created_at, :updated_at
  # Exclude sensitive fields like password_digest, tokens, etc.
end
