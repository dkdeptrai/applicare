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
class RepairerSerializer < ActiveModel::Serializer
  attributes :id, :name, :email_address, :hourly_rate, :service_radius, :latitude, :longitude, :created_at, :updated_at,
             :professional, :years_experience, :ratings_average, :reviews_count,
             :clients_count, :bio,
             :profile_picture_url, :work_image_urls

  has_many :services

  def hourly_rate
    object.hourly_rate.to_f
  end

  def profile_picture_url
    return nil unless object.profile_picture_id.present?
    Cloudinary::Utils.cloudinary_url(object.profile_picture_id, width: 200, height: 200, crop: :fill, gravity: :face, fetch_format: :auto)
  end

  def work_image_urls
    object.work_image_ids.map do |public_id|
      Cloudinary::Utils.cloudinary_url(public_id, width: 400, quality: :auto, fetch_format: :auto)
    end
  end
end
