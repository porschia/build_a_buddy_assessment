class CreateStuffedAnimals < ActiveRecord::Migration[5.1]
  def change
    create_table :stuffed_animals do |t|
      t.string :description
      t.float :cost
      t.float :sale_price
      t.integer :quantity

      t.timestamps
    end
  end
end
