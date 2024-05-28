class CreateActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :activities do |t|
      t.references :project, null: false, foreign_key: true
      t.references :activity_manager, null: false, foreign_key: { to_table: :users }
      t.string :name
      t.integer :task_count
      t.boolean :completed

      t.timestamps
    end
  end
end
