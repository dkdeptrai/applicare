# == Schema Information
#
# Table name: repairers
#
#  id                 :bigint           not null, primary key
#  address            :string           default("")
#  bio                :text
#  clients_count      :integer
#  email_address      :string           not null
#  hourly_rate        :decimal(, )
#  latitude           :float
#  longitude          :float
#  name               :string           not null
#  password_digest    :string           not null
#  professional       :boolean
#  ratings_average    :float
#  reviews_count      :integer
#  service_radius     :integer
#  work_image_ids     :jsonb            not null
#  years_experience   :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  profile_picture_id :string
#
# Indexes
#
#  index_repairers_on_email_address  (email_address) UNIQUE
#
FactoryBot.define do
  factory :repairer do
    name { Faker::Name.name }
    email_address { Faker::Internet.unique.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    hourly_rate { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    service_radius { Faker::Number.between(from: 5, to: 50) }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }

    professional { Faker::Boolean.boolean }
    years_experience { Faker::Number.between(from: 1, to: 30) }
    ratings_average { Faker::Number.between(from: 1.0, to: 5.0).round(2) }
    reviews_count { Faker::Number.between(from: 0, to: 200) }
    clients_count { Faker::Number.between(from: 0, to: 500) }
    bio { Faker::Lorem.paragraph(sentence_count: 3) }
    profile_picture_id { "profile_#{SecureRandom.hex(8)}" }
    work_image_ids { Array.new(Faker::Number.between(from: 0, to: 5)) { "work_#{SecureRandom.hex(8)}" } }
  end
end
