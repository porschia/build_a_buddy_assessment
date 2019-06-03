class CreateAccessoryCompatibilities < ActiveRecord::Migration[5.1]
  def change
    create_table :accessory_compatibilities do |t|

      t.timestamps
    end
  end
end
