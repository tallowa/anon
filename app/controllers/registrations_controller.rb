class RegistrationsController < ApplicationController
  def new
    @invite = Identity::Invite.find_by!(token: params[:token])
    
    if @invite.expired?
      render :expired
      return
    end
    
    if @invite.accepted?
      redirect_to login_path, alert: "This invite has already been used"
      return
    end
    
    @user = @invite.company.users.new(email: @invite.email)
  end
  
  def create
    @invite = Identity::Invite.find_by!(token: params[:token])
    
    if @invite.expired? || @invite.accepted?
      redirect_to login_path, alert: "Invalid or expired invite"
      return
    end
    
    @user = @invite.company.users.new(user_params)
    @user.email = @invite.email
    @user.email_verified = false
    
    if @user.save
      # Mark invite as accepted
      @invite.accept!(@user)
      
      # Create verification token
      verification_token = @user.create_email_verification_token
      
      # Log them in
      session[:user_id] = @user.id
      
      flash[:notice] = "Account created! Please verify your email. (Token: #{verification_token.token})"
      redirect_to dashboard_path
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def user_params
    params.require(:identity_user).permit(:password, :password_confirmation, :job_title, :department)
  end
end
