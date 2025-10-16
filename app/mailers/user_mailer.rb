class UserMailer < ApplicationMailer
  def verification_email(user, token)
    @user = user
    @token = token
    @verification_url = verify_email_url(token.token)
    
    mail(
      to: user_email(user),
      subject: "Verify your email for Anonymous Feedback"
    )
  end
  
  private
  
  def user_email(user)
    # Same issue as above - we need the actual email
    user.email
  end
end
