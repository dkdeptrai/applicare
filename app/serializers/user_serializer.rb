class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email_address, :address, :latitude, :longitude, :date_of_birth, :mobile_number, :onboarded, :created_at, :updated_at
  # Exclude sensitive fields like password_digest, tokens, etc.
end
