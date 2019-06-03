class CreateRelationships < ActiveRecord::Migration[5.1]
  def change
    # create the relationship between line_items and purchase_orders,
    # accessories and stuffed_animals
    add_reference :line_items, :purchase_order, index: true
    add_reference :line_items, :accessory, index: true
    add_reference :line_items, :stuffed_animal, index: true

    # create the relationship between accessorry_compatibilities and
    # accessories and stuffed_animals
    add_reference :accessory_compatibilities, :accessory, index: true
    add_reference :accessory_compatibilities, :stuffed_animal, index: true

  end
end
