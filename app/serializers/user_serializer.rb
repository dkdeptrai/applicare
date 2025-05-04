# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  address         :string           default("")
#  date_of_birth   :date
#  email_address   :string           not null
#  latitude        :float
#  longitude       :float
#  mobile_number   :string
#  name            :string           not null
#  onboarded       :boolean          default(FALSE)
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#
class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email_address, :address, :latitude, :longitude, :date_of_birth, :mobile_number, :onboarded, :created_at, :updated_at
  # Exclude sensitive fields like password_digest, tokens, etc.
end
