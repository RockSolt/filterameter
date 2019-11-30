class CreatePrices < ActiveRecord::Migration[5.2]
  def change
    create_table :prices do |t|
      t.references :shirt, foreign_key: true
      t.decimal :current, precision: 10, scale: 2
      t.decimal :original, precision: 10, scale: 2

      t.timestamps
    end
  end
end
