class CreateAnonymousProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :anonymous_profiles do |t|
      t.string :profile_hash, null: false
      
      t.jsonb :cached_summary
      t.jsonb :cached_themes
      t.datetime :last_aggregated_at
      
      t.timestamps
    end
    
    add_index :anonymous_profiles, :profile_hash, unique: true
  end
end
