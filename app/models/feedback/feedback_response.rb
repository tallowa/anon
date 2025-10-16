module Feedback
  class FeedbackResponse < Base
    self.table_name = "feedback_responses"
    
    belongs_to :feedback_request
    
    validates :content, presence: true, length: { minimum: 50 }
    validates :response_hash, presence: true, uniqueness: true
    
    before_validation :generate_response_hash, on: :create
    before_validation :set_content_length
    before_create :analyze_sentiment
    after_create :schedule_metadata_cleanup
    
    scope :recent, -> { order(created_at: :desc) }
    scope :positive, -> { where(sentiment_label: 'positive') }
    scope :neutral, -> { where(sentiment_label: 'neutral') }
    scope :negative, -> { where(sentiment_label: 'negative') }
    
    def fuzzy_time
      time_ago = Time.current - created_at
      
      case time_ago
      when 0..1.hour
        "Less than an hour ago"
      when 1.hour..6.hours
        "A few hours ago"
      when 6.hours..24.hours
        "Earlier today"
      when 1.day..3.days
        "A few days ago"
      when 3.days..7.days
        "About a week ago"
      when 7.days..14.days
        "A couple weeks ago"
      when 14.days..30.days
        "A few weeks ago"
      else
        "Over a month ago"
      end
    end
    
    def sentiment_emoji
      case sentiment_label
      when 'positive' then '😊'
      when 'neutral' then '😐'
      when 'negative' then '😞'
      else '😐'
      end
    end
    
    def sentiment_color
      case sentiment_label
      when 'positive' then 'green'
      when 'neutral' then 'gray'
      when 'negative' then 'red'
      else 'gray'
      end
    end
    
    private
    
    def generate_response_hash
      self.response_hash = SecureRandom.urlsafe_base64(32)
    end
    
    def set_content_length
      self.content_length = content.to_s.length
    end
    
    def analyze_sentiment
      analyzer = SentimentAnalyzer.new(content)
      result = analyzer.analyze
      
      self.sentiment_score = result[:score]
      self.sentiment_label = result[:label]
    end
    
    def schedule_metadata_cleanup
      CleanupMetadataJob.set(wait: 24.hours).perform_later(id)
    end
  end
end
