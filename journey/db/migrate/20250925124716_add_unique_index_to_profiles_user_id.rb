class AddUniqueIndexToProfilesUserId < ActiveRecord::Migration[8.0]
  def change
    remove_index :profiles, :user_id if index_exists?(:profiles, :user_id)
    add_index :profiles, :user_id, unique: true
  end
end
