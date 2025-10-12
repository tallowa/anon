class FeedbackRequestsController < ApplicationController
  before_action :require_login
  
  def index
    # Get or create anonymous profile for current user
    @anonymous_profile = find_or_create_anonymous_profile
    @feedback_requests = @anonymous_profile.feedback_requests.order(created_at: :desc)
  end
  
  def create
    @anonymous_profile = find_or_create_anonymous_profile
    @feedback_request = @anonymous_profile.feedback_requests.build
    
    if @feedback_request.save
      redirect_to feedback_request_path(@feedback_request), notice: "Feedback request created! Share the link below."
    else
      redirect_to feedback_requests_path, alert: "Could not create feedback request"
    end
  end
  
  def show
    @anonymous_profile = find_or_create_anonymous_profile
    @feedback_request = @anonymous_profile.feedback_requests.find(params[:id])
  end
  
  private
  
  def find_or_create_anonymous_profile
    profile_hash = current_user.anonymous_profile_id
    Feedback::AnonymousProfile.find_or_create_by!(profile_hash: profile_hash)
  end
end
