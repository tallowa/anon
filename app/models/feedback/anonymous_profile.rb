module Feedback
  class AnonymousProfile < Base
    self.table_name = "anonymous_profiles"
    
    has_many :feedback_requests, dependent: :destroy
    has_many :feedback_responses, through: :feedback_requests, source: :responses
    
    validates :profile_hash, presence: true, uniqueness: true
    
    def total_responses
      feedback_responses.count
    end
    
    def can_view_feedback?
      total_responses >= 3
    end
  end
end
