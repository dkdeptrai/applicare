require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'requires an email address' do
      user = build(:user, email_address: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email_address]).to include("can't be blank")
    end

    it 'requires a valid email format' do
      user = build(:user, email_address: 'invalid-email')
      expect(user).not_to be_valid
      expect(user.errors[:email_address]).to include("is invalid")
    end

    it 'requires a unique email address' do
      create(:user, email_address: 'test@example.com')
      user = build(:user, email_address: 'test@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email_address]).to include("has already been taken")
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
    it { is_expected.to have_many(:api_tokens).dependent(:destroy) }
  end

  describe '#generate_jwt' do
    it 'generates a JWT token with the user ID' do
      user = create(:user)
      token = user.generate_jwt
      decoded_token = JwtToken.decode(token)
      expect(decoded_token[:user_id]).to eq(user.id)
    end
  end

  describe '#generate_email_verification_token' do
    it 'generates a new token and updates the timestamp' do
      user = create(:user)
      expect(user.email_verification_token).to be_nil

      token = user.generate_email_verification_token

      expect(token).not_to be_nil
      expect(user.email_verification_token).to eq(token)
      expect(user.email_verification_sent_at).not_to be_nil
    end
  end

  describe '#verify_email!' do
    it 'marks the user as verified and clears the token' do
      user = create(:user, :unverified)
      expect(user.email_verified).to be false

      user.verify_email!

      expect(user.email_verified).to be true
      expect(user.email_verification_token).to be_nil
    end
  end

  describe '#email_verification_expired?' do
    it 'returns true if token was sent more than 24 hours ago' do
      user = create(:user, :unverified, email_verification_sent_at: 25.hours.ago)
      expect(user.email_verification_expired?).to be true
    end

    it 'returns false if token was sent less than 24 hours ago' do
      user = create(:user, :unverified, email_verification_sent_at: 23.hours.ago)
      expect(user.email_verification_expired?).to be false
    end

    it 'returns nil if no verification timestamp exists' do
      user = create(:user)
      expect(user.email_verification_expired?).to be_nil
    end
  end

  describe '#send_verification_email' do
    it 'generates a token and enqueues an email' do
      user = create(:user)

      mail = double("Mail")
      expect(VerificationMailer).to receive(:verification_email).with(user).and_return(mail)
      expect(mail).to receive(:deliver_later)

      user.send_verification_email

      expect(user.email_verification_token).not_to be_nil
      expect(user.email_verification_sent_at).not_to be_nil
    end
  end
end
