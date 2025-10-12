class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.references :company, null: false, foreign_key: true
      t.string :email_hash, null: false
      t.string :password_digest, null: false
      
      t.string :job_title
      t.string :department
      
      t.boolean :email_verified, default: false
      t.datetime :last_sign_in_at
      
      t.timestamps
    end
    
    add_index :users, :email_hash, unique: true
  end
end
