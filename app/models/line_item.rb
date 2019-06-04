class LineItem < ApplicationRecord
    belongs_to :purchase_order
    belongs_to :stuffed_animal, optional: true
    belongs_to :accessory, optional: true
end
