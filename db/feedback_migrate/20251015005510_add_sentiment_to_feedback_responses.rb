class AddSentimentToFeedbackResponses < ActiveRecord::Migration[8.0]
  def change
    add_column :feedback_responses, :sentiment_score, :float
    add_column :feedback_responses, :sentiment_label, :string
    
    add_index :feedback_responses, :sentiment_label
  end
end
