# == Schema Information
#
# Table name: bookings
#
#  id            :bigint           not null, primary key
#  address       :text
#  end_time      :datetime
#  notes         :text
#  repairer_note :text
#  start_time    :datetime
#  status        :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  repairer_id   :bigint           not null
#  service_id    :bigint           not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_bookings_on_repairer_id  (repairer_id)
#  index_bookings_on_service_id   (service_id)
#  index_bookings_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (repairer_id => repairers.id)
#  fk_rails_...  (service_id => services.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Booking, type: :model do
  let!(:repairer) { create(:repairer) }
  let!(:user) { create(:user) }
  let!(:service) { create(:service, repairer: repairer) }
  let!(:availability) { create(:availability, repairer: repairer) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      booking = build(:booking, repairer: repairer, user: user, service: service)
      expect(booking).to be_valid
    end

    it 'is not valid without a repairer' do
      booking = build(:booking, repairer: nil, user: user, service: service)
      expect(booking).not_to be_valid
    end

    it 'is not valid without a user' do
      booking = build(:booking, repairer: repairer, user: nil, service: service)
      expect(booking).not_to be_valid
    end

    it 'is not valid without a service' do
      booking = build(:booking, repairer: repairer, user: user, service: nil)
      expect(booking).not_to be_valid
    end

    it 'is not valid without a start_time' do
      booking = build(:booking, repairer: repairer, user: user, service: service, start_time: nil)
      expect(booking).not_to be_valid
    end

    it 'is not valid without a status' do
      booking = build(:booking, repairer: repairer, user: user, service: service, status: nil)
      expect(booking).not_to be_valid
    end

    it 'is not valid without an address' do
      booking = build(:booking, repairer: repairer, user: user, service: service, address: nil)
      expect(booking).not_to be_valid
    end
  end

  describe 'time slot validation' do
    it 'is valid when time slot is within repairer\'s availability' do
      # Set start_time to next Monday at 10:00 AM
      next_monday = Time.current.next_occurring(:monday).beginning_of_day + 10.hours
      booking = build(:booking, repairer: repairer, user: user, service: service, start_time: next_monday)
      expect(booking).to be_valid
    end

    it 'is not valid when time slot is outside repairer\'s availability' do
      # Set start_time to next Monday at 8:00 AM (before availability)
      next_monday = Time.current.next_occurring(:monday).beginning_of_day + 8.hours
      booking = build(:booking, repairer: repairer, user: user, service: service, start_time: next_monday)
      expect(booking).not_to be_valid
      expect(booking.errors[:base]).to include('time slot is not within repairer\'s availability')
    end
  end

  describe 'status transitions' do
    it 'allows transition from pending to confirmed' do
      booking = create(:booking, repairer: repairer, user: user, service: service)
      booking.status = 'confirmed'
      expect(booking).to be_valid
      expect(booking.status).to eq('confirmed')
    end

    it 'allows transition from pending to cancelled' do
      booking = create(:booking, repairer: repairer, user: user, service: service)
      booking.status = 'cancelled'
      expect(booking).to be_valid
      expect(booking.status).to eq('cancelled')
    end

    it 'allows transition from confirmed to completed' do
      booking = create(:booking, :confirmed, repairer: repairer, user: user, service: service)
      booking.status = 'completed'
      expect(booking).to be_valid
      expect(booking.status).to eq('completed')
    end
  end

  describe 'duration calculation' do
    it 'calculates end_time based on service duration' do
      service = create(:service, duration_minutes: 60)
      start_time = Time.current.next_occurring(:monday).beginning_of_day + 10.hours
      booking = create(:booking, repairer: repairer, user: user, service: service, start_time: start_time)
      expect(booking.end_time).to eq(start_time + 60.minutes)
    end
  end
end
