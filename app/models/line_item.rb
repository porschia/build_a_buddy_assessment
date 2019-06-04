class LineItem < ApplicationRecord
    belongs_to :purchase_order
    belongs_to :stuffed_animal, optional: true
    belongs_to :accessory, optional: true

    after_create :suggest_other_product

    # method to suggest a product that was historically purchased with this
    # item
    def suggest_other_product
        po = self.purchase_order
        purchased_item = self.stuffed_animal.present? ? self.stuffed_animal : self.accessory
        suggested_item = po.similarly_purchased_item purchased_item
    end
end
