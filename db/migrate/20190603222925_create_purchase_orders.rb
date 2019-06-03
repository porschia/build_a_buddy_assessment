class CreatePurchaseOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :purchase_orders do |t|
      t.date :date
      t.time :time

      t.timestamps
    end
  end
end
