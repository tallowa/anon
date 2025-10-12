class DashboardController < ApplicationController
  before_action :require_login
  
  def index
    @anonymous_profile = find_or_create_anonymous_profile
    @recent_requests = @anonymous_profile.feedback_requests.order(created_at: :desc).limit(5)
    @total_responses = @anonymous_profile.total_responses
  end
  
  private
  
  def find_or_create_anonymous_profile
    profile_hash = current_user.anonymous_profile_id
    Feedback::AnonymousProfile.find_or_create_by!(profile_hash: profile_hash)
  end
end
