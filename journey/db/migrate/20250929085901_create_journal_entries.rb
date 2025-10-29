class CreateJournalEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :journal_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.date :entry_date, null: false
      t.time :time_from
      t.time :time_to
      t.timestamps
    end

    add_index :journal_entries, %i(user_id entry_date)
  end
end
