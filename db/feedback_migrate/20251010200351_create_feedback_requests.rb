class CreateFeedbackRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :feedback_requests do |t|
      t.references :anonymous_profile, null: false, foreign_key: true
      
      t.string :token, null: false
      t.datetime :expires_at, null: false
      
      t.jsonb :questions, default: []
      
      t.boolean :active, default: true
      t.integer :response_count, default: 0
      
      t.timestamps
    end
    
    add_index :feedback_requests, :token, unique: true
    add_index :feedback_requests, :expires_at
  end
end
