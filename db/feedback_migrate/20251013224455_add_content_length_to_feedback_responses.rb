class AddContentLengthToFeedbackResponses < ActiveRecord::Migration[8.0]
  def change
    add_column :feedback_responses, :content_length, :integer
  end
end
