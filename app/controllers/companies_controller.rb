class CompaniesController < ApplicationController
  def new
    @company = Identity::Company.new
  end
  
  def create
    @company = Identity::Company.new(company_params)
    
    if @company.save
      # Create first admin user
      first_user = @company.users.new(
        email: params[:admin_email],
        password: params[:admin_password],
        password_confirmation: params[:admin_password_confirmation],
        job_title: "Admin",
        email_verified: false
      )
      
      if first_user.save
        # Create verification token
        verification_token = first_user.create_email_verification_token
        
        # Log them in
        session[:user_id] = first_user.id
        
        # In production, you'd send an email here
        flash[:notice] = "Company created! Please verify your email. (Token: #{verification_token.token})"
        redirect_to dashboard_path
      else
        @company.destroy
        @error = first_user.errors.full_messages.join(", ")
        render :new, status: :unprocessable_entity
      end
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def company_params
    # Changed from :company to :identity_company
    params.require(:identity_company).permit(:name, :domain)
  end
end
