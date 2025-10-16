class InviteMailer < ApplicationMailer
  def team_invitation(invite)
    @invite = invite
    @company = invite.company
    @invited_by = invite.invited_by
    @signup_url = signup_url(invite_token: invite.token)
    
    mail(
      to: invite.email,
      subject: "#{@invited_by.display_name} invited you to join #{@company.name} on Anonymous Feedback"
    )
  end
end
