class CleanupMetadataJob < ApplicationJob
  queue_as :default

  def perform(feedback_response_id)
    response = Feedback::FeedbackResponse.find_by(id: feedback_response_id)
    
    return unless response
    
    # Delete identifying metadata after 24 hours
    response.update_columns(
      ip_address: nil,
      user_agent: nil
    )
    
    Rails.logger.info "Cleaned metadata for FeedbackResponse ##{feedback_response_id}"
  end
end
