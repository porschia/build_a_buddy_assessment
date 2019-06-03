class StuffedAnimal < ApplicationRecord
    has_many :accessories, through: :accessory_compatibilities
    has_many :purchase_orders, through: :line_items
end
