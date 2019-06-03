class PurchaseOrder < ApplicationRecord
    has_many :stuffed_animals, through: :line_items
    has_many :accessory, through: :line_items
end
