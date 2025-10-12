class EmailVerificationsController < ApplicationController
  def show
    @token = Identity::VerificationToken.valid_tokens.find_by!(token: params[:token])
    
    if @token.expired?
      redirect_to dashboard_path, alert: "Verification link has expired"
      return
    end
    
    @user = @token.user
    @user.update!(email_verified: true)
    @token.mark_as_used!
    
    redirect_to dashboard_path, notice: "Email verified successfully!"
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_path, alert: "Invalid verification link"
  end
end
