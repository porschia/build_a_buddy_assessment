class Accessory < ApplicationRecord
    has_many :accessory_compatibilities
    has_many :line_items
    has_many :stuffed_animals, through: :accessory_compatibilities
    has_many :purchase_orders, through: :line_items
end
