class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.references :team, null: false, foreign_key: true
      t.references :journal_entry, null: true, foreign_key: true
      t.bigint :creator_id, null: false
      t.bigint :assignee_id, null: true

      t.string :title, null: false
      t.text :notes
      t.integer :status, null: false, default: 0
      t.date :due_on

      t.timestamps
    end

    add_foreign_key :tasks, :users, column: :creator_id
    add_foreign_key :tasks, :users, column: :assignee_id
    add_index :tasks, :status
    add_index :tasks, :due_on
  end
end
