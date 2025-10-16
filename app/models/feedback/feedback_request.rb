module Feedback
  class FeedbackRequest < Base
    self.table_name = "feedback_requests"
    
    belongs_to :anonymous_profile
    has_many :responses, class_name: 'FeedbackResponse', dependent: :destroy
    
    validates :token, presence: true, uniqueness: true
    validates :expires_at, presence: true
    
    before_validation :generate_token, on: :create
    before_validation :ensure_questions_is_array
    
    scope :active, -> { where('expires_at > ?', Time.current).where(active: true) }
    scope :expired, -> { where('expires_at <= ?', Time.current) }
    
    def expired?
      expires_at <= Time.current
    end
    
    def can_reveal_feedback?
      responses.count >= 3
    end
    
    def shareable_url
      "#{ENV.fetch('APP_URL', 'http://localhost:3000')}/feedback/#{token}"
    end
    
    # Ensure questions is always an array
    def questions
      value = read_attribute(:questions)
      return default_questions if value.blank?
      return value if value.is_a?(Array)
      
      # If it's a string, try to parse it
      begin
        JSON.parse(value)
      rescue
        default_questions
      end
    end
    
    private
    
    def generate_token
      self.token = SecureRandom.urlsafe_base64(32)
      self.expires_at = 30.days.from_now
    end
    
    def ensure_questions_is_array
      self.questions = default_questions if read_attribute(:questions).blank?
    end
    
    def default_questions
      [
        { 'id' => 1, 'text' => "What should this person keep doing?" },
        { 'id' => 2, 'text' => "What's one area where they could improve?" },
        { 'id' => 3, 'text' => "How effectively do they communicate?" },
        { 'id' => 4, 'text' => "Any additional thoughts?" }
      ]
    end
  end
end
