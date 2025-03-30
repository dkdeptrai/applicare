class VerificationMailer < ApplicationMailer
  def verification_email(user)
    @user = user
    @verification_url = verify_email_url(token: user.email_verification_token)
    mail(to: user.email_address, subject: "Verify your email address")
  end
end
