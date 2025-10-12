class CleanupMetadataJob < ApplicationJob
  queue_as :security
  
  def perform(response_id)
    response = Feedback::FeedbackResponse.find_by(id: response_id)
    return unless response
    
    response.update!(
      ip_address: nil,
      user_agent: nil
    )
    
    Rails.logger.info "Cleaned metadata for response #{response_id}"
  end
end
