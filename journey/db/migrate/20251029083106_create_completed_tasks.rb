class CreateCompletedTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :completed_tasks do |t|
      t.references :team, null: false, foreign_key: true

      t.references :task,
                   null: true,
                   index: false,
                   foreign_key: { to_table: :tasks, on_delete: :nullify }

      t.references :assignee, null: false, foreign_key: { to_table: :users }
      t.datetime :completed_at, null: false

      t.timestamps
    end

    add_index :completed_tasks,
              :task_id,
              unique: true,
              where: 'task_id IS NOT NULL',
              name: 'index_completed_tasks_on_task_id_partial'

    add_index :completed_tasks, %i(team_id assignee_id)
    add_index :completed_tasks, :completed_at
  end
end
