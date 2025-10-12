class InvitesController < ApplicationController
  before_action :require_login
  
  def index
    @invites = current_user.company.invites.order(created_at: :desc)
    @pending_invites = @invites.pending
  end
  
  def create
    unless current_user.company.can_add_users?
      redirect_to invites_path, alert: "User limit reached for your company"
      return
    end
    
    @invite = current_user.sent_invites.build(invite_params)
    @invite.company = current_user.company
    
    if @invite.save
      # In production, send email here with the invite link
      invite_url = register_url(@invite.token)
      
      flash[:notice] = "Invite sent! Share this link: #{invite_url}"
      redirect_to invites_path
    else
      @invites = current_user.company.invites.order(created_at: :desc)
      @pending_invites = @invites.pending
      flash.now[:alert] = @invite.errors.full_messages.join(", ")
      render :index, status: :unprocessable_entity      
    end
  end
  
  private
  
  def invite_params
    params.require(:identity_invite).permit(:email)
  end
end
