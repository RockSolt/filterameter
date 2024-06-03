class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.references :activity, null: false, foreign_key: true
      t.string :description
      t.boolean :completed

      t.timestamps
    end
  end
end
