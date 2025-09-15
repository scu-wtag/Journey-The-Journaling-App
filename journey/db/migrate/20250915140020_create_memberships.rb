class CreateMemberships < ActiveRecord::Migration[8.0]
  def change
    return if table_exists?(:memberships)

    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.integer :role, null: false, default: 0
      t.timestamps
    end
  end
end