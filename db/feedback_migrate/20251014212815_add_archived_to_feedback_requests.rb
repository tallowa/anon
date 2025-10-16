class AddArchivedToFeedbackRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :feedback_requests, :archived, :boolean, default: false
    add_index :feedback_requests, :archived
  end
end
