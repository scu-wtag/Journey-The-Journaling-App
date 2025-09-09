class AddNameAndRoleToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :name, :string
    add_column :users, :role, :integer, null: false, default: 1
    add_index  :users, :role
  end
end
