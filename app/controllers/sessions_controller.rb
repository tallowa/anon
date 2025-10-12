class SessionsController < ApplicationController
  def new
    # Login form
  end
  
  def create
    # For now, simple email/password login
    # Find user by email (we'll need to modify this since we hash emails)
    company = Identity::Company.find_by(domain: email_domain(params[:email]))
    
    if company
      user = company.users.find do |u|
        BCrypt::Password.new(u.email_hash) == params[:email]
      rescue BCrypt::Errors::InvalidHash
        false
      end
      
      if user&.authenticate(params[:password])
        session[:user_id] = user.id
        redirect_to dashboard_path, notice: "Logged in successfully!"
      else
        flash.now[:alert] = "Invalid email or password"
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Logged out successfully!"
  end
  
  private
  
  def email_domain(email)
    email.split('@').last if email.include?('@')
  end
end
