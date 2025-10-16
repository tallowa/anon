class AddAcceptedByUserIdToInvites < ActiveRecord::Migration[8.0]
  def change
    add_column :invites, :accepted_by_user_id, :integer
    add_index :invites, :accepted_by_user_id
  end
end
