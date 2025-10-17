class SentimentAnalyzer
  POSITIVE_WORDS = %w[
    great excellent amazing outstanding fantastic wonderful superb
    awesome exceptional brilliant good better best improved improving
    helpful effective clear strong skilled talented creative innovative
    productive efficient reliable consistent thorough professional
    collaborative supportive encouraging positive constructive
    appreciate appreciated thank thanks grateful love enjoy impressive
    solid quality exceptional
  ].freeze
  
  NEGATIVE_WORDS = %w[
    terrible awful horrible poor bad worse worst lacking struggle
    difficult challenging problematic concerning worried disappointing
    frustrated frustrating confusing unclear inconsistent unreliable
    late delayed missed missing inadequate insufficient weak
    unprofessional careless sloppy rushed needs improvement
    concern concerns issue issues problem problems mistake mistakes
    fail failed failing failure poorly
  ].freeze
  
  NEGATIVE_PHRASES = [
    'room for improvement', 'could be better', 'needs work',
    'needs improvement', 'could improve', 'should improve',
    'falling short', 'not meeting', 'behind schedule',
    'missed deadline', 'need to see', 'more attention', 'work on'
  ].freeze
  
  def initialize(text)
    @text = text&.downcase || ""
  end
  
  def analyze
    return default_result if @text.blank?
    
    # Count positive and negative indicators
    positive_count = count_words(POSITIVE_WORDS)
    negative_count = count_words(NEGATIVE_WORDS) + count_phrases(NEGATIVE_PHRASES)
    
    # Calculate score based on ratio
    total = positive_count + negative_count
    
    if total.zero?
      score = 0.0
    else
      # Score from -1 to 1 based on positive vs negative ratio
      score = ((positive_count - negative_count).to_f / total).round(2)
    end
    
    # Classify
    label = classify_sentiment(score)
    
    {
      score: score,
      label: label,
      emoji: emoji_for_label(label),
      color: color_for_label(label)
    }
  end
  
  private
  
  def count_words(word_list)
    words = @text.split(/\W+/)
    words.count { |word| word_list.include?(word) }
  end
  
  def count_phrases(phrase_list)
    phrase_list.count { |phrase| @text.include?(phrase) }
  end
  
  def classify_sentiment(score)
    case score
    when 0.15..Float::INFINITY
      'positive'
    when -0.15..0.15
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
