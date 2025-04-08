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
end
