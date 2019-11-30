class CreateVendors < ActiveRecord::Migration[5.2]
  def change
    create_table :vendors do |t|
      t.string :name
      t.integer :ship_time_in_days

      t.timestamps
    end
  end
end
