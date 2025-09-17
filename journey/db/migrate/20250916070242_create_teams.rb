class CreateTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :teams, :name
  end
end
