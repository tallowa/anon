module Feedback
  class FeedbackResponse < Base
    self.table_name = "feedback_responses"
    
    belongs_to :feedback_request, counter_cache: :response_count
    
    validates :content, presence: true, length: { minimum: 50, maximum: 2000 }
    validates :response_hash, presence: true, uniqueness: true
    
    before_validation :generate_response_hash
    after_create :schedule_metadata_cleanup
    
    scope :recent, -> { order(created_at: :desc) }
    scope :flagged, -> { where(flagged: true) }
    
    def fuzzy_time
      days_ago = ((Time.current - created_at) / 1.day).to_i
      
      case days_ago
      when 0 then "today"
      when 1 then "yesterday"
      when 2..6 then "this week"
      when 7..29 then "this month"
      else "a while ago"
      end
    end
    
    private
    
    def generate_response_hash
      return if response_hash.present?
      
      self.response_hash = Digest::SHA256.hexdigest([
        ip_address,
        feedback_request_id,
        Date.current.to_s,
        Rails.application.secret_key_base
      ].join('-'))
    end
    
    def schedule_metadata_cleanup
      CleanupMetadataJob.set(wait: 24.hours).perform_later(id)
    end
  end
end
