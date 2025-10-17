class SentimentAnalyzer
  def initialize(text)
    @text = text
    @analyzer = Sentimental.new  # This is the VADER gem
  end
  
  def analyze
    return default_result if @text.blank?
    
    # VADER returns a hash with compound, pos, neu, neg scores
    result = @analyzer.polarity_scores(@text)
    
    # Use compound score (-1 to 1)
    score = result[:compound]
    
    # Classify based on score
    label = classify_sentiment(score)
    
    {
      score: score.round(2),
      label: label,
      emoji: emoji_for_label(label),
      color: color_for_label(label)
    }
  end
  
  private
  
  def classify_sentiment(score)
    # VADER thresholds: >= 0.05 is positive, <= -0.05 is negative
    case score
    when 0.05..Float::INFINITY
      'positive'
    when -0.05..0.05
      'neutral'
    else
      'negative'
    end
  end
  
  def emoji_for_label(label)
    case label
    when 'positive' then '😊'
    when 'neutral' then '😐'
    when 'negative' then '😞'
    end
  end
  
  def color_for_label(label)
    case label
    when 'positive' then 'green'
    when 'neutral' then 'gray'
    when 'negative' then 'red'
    end
  end
  
  def default_result
    {
      score: 0.0,
      label: 'neutral',
      emoji: '😐',
      color: 'gray'
    }
  end
end
