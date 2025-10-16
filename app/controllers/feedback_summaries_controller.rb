require 'csv'

class FeedbackSummariesController < ApplicationController
  before_action :require_login
  
  def show
    @anonymous_profile = find_anonymous_profile
    @feedback_requests = @anonymous_profile.feedback_requests.includes(:responses)
    @total_responses = @anonymous_profile.total_responses
    @can_view = @anonymous_profile.can_view_feedback?
    
    if @can_view
      @all_responses = @anonymous_profile.feedback_responses.recent
      
      # Analytics data
      @responses_by_day = @anonymous_profile.feedback_responses
        .group_by_day(:created_at, last: 30)
        .count
      
      @average_response_length = @anonymous_profile.feedback_responses
        .average(:content_length)
        .to_i
      
      @most_recent_feedback = @anonymous_profile.feedback_responses
        .order(created_at: :desc)
        .limit(1)
        .first
      
      @feedback_frequency = calculate_feedback_frequency
      
      # Sentiment statistics
      @sentiment_breakdown = {
        positive: @anonymous_profile.feedback_responses.positive.count,
        neutral: @anonymous_profile.feedback_responses.neutral.count,
        negative: @anonymous_profile.feedback_responses.negative.count
      }
      
      @average_sentiment_score = @anonymous_profile.feedback_responses
        .average(:sentiment_score)
        .to_f
        .round(2)
      
      @sentiment_over_time = @anonymous_profile.feedback_responses
        .group_by_day(:created_at, last: 30)
        .average(:sentiment_score)
    end
  end
  
  def export_pdf
    @anonymous_profile = find_anonymous_profile
    
    unless @anonymous_profile.can_view_feedback?
      redirect_to my_feedback_path, alert: "Need at least 3 responses to export"
      return
    end
    
    @responses = @anonymous_profile.feedback_responses.order(created_at: :desc)
    
    pdf = FeedbackPdfGenerator.new(current_user, @responses).generate
    
    send_data pdf,
      filename: "feedback-#{current_user.display_name.parameterize}-#{Date.current}.pdf",
      type: "application/pdf",
      disposition: "attachment"
  end
  
  def export_csv
    @anonymous_profile = find_anonymous_profile
    
    unless @anonymous_profile.can_view_feedback?
      redirect_to my_feedback_path, alert: "Need at least 3 responses to export"
      return
    end
    
    @responses = @anonymous_profile.feedback_responses.order(created_at: :desc)
    
    csv_data = generate_csv(@responses)
    
    send_data csv_data,
      filename: "feedback-#{current_user.display_name.parameterize}-#{Date.current}.csv",
      type: "text/csv",
      disposition: "attachment"
  end
  
  private
  
  def find_anonymous_profile
    profile_hash = current_user.anonymous_profile_id
    Feedback::AnonymousProfile.find_or_create_by!(profile_hash: profile_hash)
  end
  
  def calculate_feedback_frequency
    return "N/A" if @total_responses < 2
    
    first = @anonymous_profile.feedback_responses.order(:created_at).first
    last = @anonymous_profile.feedback_responses.order(:created_at).last
    
    days = (last.created_at - first.created_at) / 1.day
    return "N/A" if days.zero?
    
    "#{(@total_responses / days).round(1)} per day"
  end
  def generate_csv(responses)
  CSV.generate(headers: true) do |csv|
    # Header row - add question columns
    headers = ["Response #", "Date", "Time Ago", "Sentiment", "Sentiment Score", "Length (chars)"]
    
    # Get all unique questions from the first response to use as column headers
    if responses.first&.feedback_request&.questions.present?
      responses.first.feedback_request.questions.each_with_index do |question, idx|
        headers << "Q#{idx + 1}: #{question['text']}"
      end
    end
    
    headers << "Overall Feedback"
    
    csv << headers
    
    # Data rows
    responses.each_with_index do |response, index|
      row = [
        index + 1,
        response.created_at.strftime("%Y-%m-%d %H:%M"),
        response.fuzzy_time,
        response.sentiment_label,
        response.sentiment_score,
        response.content_length
      ]
      
      # Add question responses
      if response.feedback_request.questions.present?
        response.feedback_request.questions.each do |question|
          answer = response.question_responses[question['id'].to_s]
          row << (answer.present? ? answer : "")
        end
      end
      
      # Add overall feedback
      row << response.content
      
      csv << row
    end
  end
end  

end
