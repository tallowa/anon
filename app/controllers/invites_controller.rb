class InvitesController < ApplicationController
  before_action :require_login
  
  def index
    @pending_invites = current_user.company.invites.pending.order(created_at: :desc)
    @accepted_invites = current_user.company.invites.accepted.order(accepted_at: :desc)
    @expired_invites = current_user.company.invites.expired.order(created_at: :desc)
  end
  
  def new
    @invite = current_user.company.invites.build
  end
  
  def create
    @invite = current_user.company.invites.build(invite_params)
    @invite.invited_by = current_user
    
    if @invite.save
      # Send invitation email
      InviteMailer.team_invitation(@invite).deliver_later
      
      redirect_to invites_path, notice: "Invitation sent to #{@invite.email}"
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def invite_params
    params.require(:identity_invite).permit(:email)
  end
end
