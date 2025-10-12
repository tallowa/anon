class FeedbackSummariesController < ApplicationController
  before_action :require_login
  
  def show
    @anonymous_profile = find_anonymous_profile
    @feedback_requests = @anonymous_profile.feedback_requests.includes(:responses)
    @total_responses = @anonymous_profile.total_responses
    @can_view = @anonymous_profile.can_view_feedback?
    
    if @can_view
      @all_responses = @anonymous_profile.feedback_responses.recent
    end
  end
  
  private
  
  def find_anonymous_profile
    profile_hash = current_user.anonymous_profile_id
    Feedback::AnonymousProfile.find_or_create_by!(profile_hash: profile_hash)
  end
end
