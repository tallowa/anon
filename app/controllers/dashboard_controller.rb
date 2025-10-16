class DashboardController < ApplicationController
  before_action :require_login
  
  def index
    @anonymous_profile = find_or_create_anonymous_profile
    
    # Only count ACTIVE (non-archived) requests
    @active_requests_count = @anonymous_profile.feedback_requests.where(archived: false).count
    
    # Get recent active requests
    @recent_requests = @anonymous_profile.feedback_requests
      .where(archived: false)
      .order(created_at: :desc)
      .limit(5)
    
    @total_responses = @anonymous_profile.total_responses
    @can_view_feedback = @anonymous_profile.can_view_feedback?
  end
  
  private
  
  def find_or_create_anonymous_profile
    profile_hash = current_user.anonymous_profile_id
    Feedback::AnonymousProfile.find_or_create_by!(profile_hash: profile_hash)
  end
end
