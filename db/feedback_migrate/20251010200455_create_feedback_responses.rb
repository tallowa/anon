class CreateFeedbackResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :feedback_responses do |t|
      t.references :feedback_request, null: false, foreign_key: true
      
      t.text :content, null: false
      t.jsonb :ratings, default: {}
      
      t.string :response_hash, null: false
      
      t.string :ip_address
      t.string :user_agent
      
      t.boolean :flagged, default: false
      t.string :flag_reason
      
      t.timestamps
    end
    
    add_index :feedback_responses, :response_hash, unique: true
    add_index :feedback_responses, :created_at
    add_index :feedback_responses, :flagged
  end
end
