class PurchaseOrder < ApplicationRecord
    has_many :line_items
    has_many :stuffed_animals, through: :line_items
    has_many :accessories, :through => :line_items

    # method to find other line items associated with previous purchases
    def self.people_also_bought

    end
end
