require "rails_helper"

RSpec.describe VerificationMailer, type: :mailer do
  describe "verification_email" do
    let(:user) { create(:user, :unverified) }
    let(:mail) { VerificationMailer.verification_email(user) }

    it "renders the headers" do
      expect(mail.subject).to eq("Verify your email address")
      expect(mail.to).to eq([ user.email_address ])
      expect(mail.from).to eq([ "from@example.com" ]) # Adjust based on your application's default from address
    end

    it "renders the body with verification url" do
      expect(mail.body.encoded).to include("Verify My Email")
      expect(mail.body.encoded).to include(user.email_verification_token)
    end
  end
end
