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
    
    if @feedback_response.save
      redirect_to feedback_thanks_path(@feedback_request.token)
    else
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
end
