class FeedbackMailer < ApplicationMailer
  def new_feedback_notification(user, feedback_response)
    @user = user
    @response = feedback_response
    @total_responses = find_total_responses(user)
    @can_view = @total_responses >= 3
    @feedback_url = my_feedback_url
    
    mail(
      to: user_email(user),
      subject: "You received new anonymous feedback!"
    )
  end
  
  private
  
  def find_total_responses(user)
    profile = Feedback::AnonymousProfile.find_by(profile_hash: user.anonymous_profile_id)
    profile&.total_responses || 0
  end
  
  def user_email(user)
    # We need to store the actual email temporarily for sending
    # This is a challenge with our hashed email system
    # For now, we'll need to handle this differently
    user.email
  end
end
