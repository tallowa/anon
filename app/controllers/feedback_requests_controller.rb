class FeedbackRequestsController < ApplicationController
  before_action :require_login
  before_action :set_feedback_request, only: [:show, :edit, :update, :archive, :unarchive]
  
  def index
    @anonymous_profile = find_or_create_anonymous_profile
    
    # Show active (non-archived) by default
    @active_requests = @anonymous_profile.feedback_requests
      .where(archived: false)
      .order(created_at: :desc)
    
    @archived_requests = @anonymous_profile.feedback_requests
      .where(archived: true)
      .order(created_at: :desc)
    
    # Show archived tab if requested
    @show_archived = params[:show] == 'archived'
  end
  
  def new
    @anonymous_profile = find_or_create_anonymous_profile
    @feedback_request = @anonymous_profile.feedback_requests.build
    
    # Set default questions if none exist
    @feedback_request.questions = default_questions if @feedback_request.questions.blank?
  end
  
  def create
    @anonymous_profile = find_or_create_anonymous_profile
    @feedback_request = @anonymous_profile.feedback_requests.build(feedback_request_params)
    
    if @feedback_request.save
      redirect_to feedback_request_path(@feedback_request), notice: "Feedback request created! Share the link below."
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def show
    # Already set by before_action
  end
  
  def edit
    # Already set by before_action
  end
  
  def update
    if @feedback_request.update(feedback_request_params)
      redirect_to feedback_request_path(@feedback_request), notice: "Questions updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def archive
    @feedback_request.update(archived: true)
    redirect_to feedback_requests_path, notice: "Request archived successfully"
  end
  
  def unarchive
    @feedback_request.update(archived: false)
    redirect_to feedback_requests_path(show: 'archived'), notice: "Request restored successfully"
  end
  
  private
  
  def find_or_create_anonymous_profile
    profile_hash = current_user.anonymous_profile_id
    Feedback::AnonymousProfile.find_or_create_by!(profile_hash: profile_hash)
  end
  
  def set_feedback_request
    @anonymous_profile = find_or_create_anonymous_profile
    @feedback_request = @anonymous_profile.feedback_requests.find(params[:id])
  end
  
  def feedback_request_params
    params.require(:feedback_feedback_request).permit(questions: [:id, :text])
  end
  
  def default_questions
    [
      { id: 1, text: "What should this person keep doing?" },
      { id: 2, text: "What's one area where they could improve?" },
      { id: 3, text: "How effectively do they communicate?" },
      { id: 4, text: "Any additional thoughts?" }
    ]
  end
end
