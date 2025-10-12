class AddFieldsToCompanies < ActiveRecord::Migration[8.0]
  def change
    add_column :companies, :logo_url, :string
    add_column :companies, :max_users, :integer, default: 50
  end
end
