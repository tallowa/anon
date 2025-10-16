class CompaniesController < ApplicationController
  def new
    @company = Identity::Company.new
    @user = Identity::User.new
    @using_invite = false
    
    # Check if there's an invite token
    if params[:invite_token].present?
      @invite = Identity::Invite.find_by(token: params[:invite_token])
      
      if @invite && @invite.pending?
        # Pre-fill email from invite
        @user.email = @invite.email
        @company = @invite.company
        @using_invite = true
      elsif @invite && @invite.accepted?
        redirect_to login_path, alert: "This invite has already been used"
        return
      elsif @invite && @invite.expired?
        redirect_to signup_path, alert: "This invite has expired. Please request a new one."
        return
      end
    end
  end
  
  def create
    # Check for invite token first
    invite = nil
    if params[:invite_token].present?
      invite = Identity::Invite.find_by(token: params[:invite_token])
      
      if invite && invite.pending?
        # Use the invite's company - don't create new one
        @company = invite.company
        @user = @company.users.build(user_params)
        @using_invite = true
      else
        # Invalid invite
        redirect_to signup_path, alert: "Invalid or expired invitation"
        return
      end
    else
      # No invite token, create new company
      @company = Identity::Company.new(company_params)
      @using_invite = false
      
      # Save company first so it has an ID
      unless @company.save
        @user = Identity::User.new(user_params)
        render :new, status: :unprocessable_entity
        return
      end
      
      # Now build user with saved company
      @user = @company.users.build(user_params)
    end
    
    if @user.save
      # Mark invite as accepted if it was used
      invite&.mark_as_accepted!(@user) if invite
      
      session[:user_id] = @user.id
      
      redirect_to dashboard_path, notice: "Welcome! Your account has been created."
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def company_params
    # Only permit company params if not using invite
    return {} if params[:invite_token].present?
    params.require(:company).permit(:name, :email_domain)
  end
  
  def user_params
    params.require(:identity_user).permit(:email, :password, :password_confirmation, :job_title, :first_name, :last_name)
  end
end
