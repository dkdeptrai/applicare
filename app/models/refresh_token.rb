# == Schema Information
#
# Table name: refresh_tokens
#
#  id          :bigint           not null, primary key
#  expires_at  :datetime
#  token       :string
#  used        :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  repairer_id :bigint
#  user_id     :bigint
#
# Indexes
#
#  index_refresh_tokens_on_repairer_id  (repairer_id)
#  index_refresh_tokens_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (repairer_id => repairers.id)
#  fk_rails_...  (user_id => users.id)
#
class RefreshToken < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :repairer, optional: true

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validate :validate_owner

  before_validation :set_default_values, on: :create

  scope :active, -> { where(used: false).where("expires_at > ?", Time.current) }

  def self.generate_for_user(user)
    create(user: user)
  end

  def self.generate_for_repairer(repairer)
    create(repairer: repairer)
  end

  def valid_for_refresh?
    !used? && expires_at > Time.current
  end

  def mark_as_used!
    update(used: true)
  end

  def owner
    user || repairer
  end

  private

  def set_default_values
    self.token ||= SecureRandom.hex(32)
    self.expires_at ||= 30.days.from_now
    self.used = false if used.nil?
  end

  def validate_owner
    errors.add(:base, "Must belong to either a user or a repairer") unless user.present? ^ repairer.present?
  end
end
