class LineItem < ApplicationRecord
    belongs_to :purchase_order
    belongs_to :stuffed_animal
    belongs_to :accessory
end
