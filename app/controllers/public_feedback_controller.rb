class PublicFeedbackController < ApplicationController
  # No authentication required - this is public!
  
  def new
    @feedback_request = Feedback::FeedbackRequest.find_by!(token: params[:token])
    
    if @feedback_request.expired?
      render :expired
      return
    end
    
    @feedback_response = @feedback_request.responses.build
  end
  
  def create
    @feedback_request = Feedback::FeedbackRequest.find_by!(token: params[:token])
    
    if @feedback_request.expired?
      render :expired, status: :gone
      return
    end
    
    @feedback_response = @feedback_request.responses.build(feedback_response_params)
    @feedback_response.ip_address = request.remote_ip
    @feedback_response.user_agent = request.user_agent
    
    # Extract question responses from params
    question_responses = extract_question_responses
    @feedback_response.question_responses = question_responses
    
    if @feedback_response.save
      # Send notification email
      notify_feedback_recipient(@feedback_request)
      
      redirect_to feedback_thanks_path(@feedback_request.token)
    else
      flash.now[:alert] = @feedback_response.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end
  
  def thanks
    @feedback_request = Feedback::FeedbackRequest.find_by!(token: params[:token])
  end
  
  private
  
  def feedback_response_params
    params.require(:feedback_feedback_response).permit(:content, ratings: {})
  end
  
  def extract_question_responses
    responses = {}
    
    # Look for all question_X parameters
    params[:feedback_response]&.each do |key, value|
      if key.to_s.start_with?('question_') && value.present?
        question_id = key.to_s.split('_').last
        responses[question_id] = value
      end
    end
    
    responses
  end
  
  def notify_feedback_recipient(feedback_request)
    profile = feedback_request.anonymous_profile
    
    # Find the user for this profile
    Identity::User.find_each do |user|
      if user.anonymous_profile_id == profile.profile_hash
        # Only send email if user has an email address
        if user.email.present?
          FeedbackMailer.new_feedback_notification(user, @feedback_response).deliver_now
        else
          Rails.logger.info "Skipping email notification - user #{user.id} has no email"
        end
        break
      end
    end
  end
end
