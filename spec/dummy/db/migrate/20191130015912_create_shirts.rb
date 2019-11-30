class CreateShirts < ActiveRecord::Migration[5.2]
  def change
    create_table :shirts do |t|
      t.references :brand, foreign_key: true
      t.string :color
      t.string :size

      t.timestamps
    end
  end
end
