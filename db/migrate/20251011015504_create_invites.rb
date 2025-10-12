class CreateInvites < ActiveRecord::Migration[8.0]
  def change
    create_table :invites do |t|
      t.references :company, null: false, foreign_key: true
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      
      t.string :email, null: false
      t.string :token, null: false
      t.datetime :expires_at, null: false
      
      t.boolean :accepted, default: false
      t.datetime :accepted_at
      
      t.timestamps
    end
    
    add_index :invites, :token, unique: true
    add_index :invites, :email
  end
end
