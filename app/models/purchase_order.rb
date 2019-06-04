class PurchaseOrder < ApplicationRecord
    has_many :line_items
    has_many :stuffed_animals, through: :line_items
    has_many :accessories, :through => :line_items

    # method to find other line items associated with previous purchases
    def similarly_purchased_item(item = nil)
        if item.present?
            # first we have to determine if this is a stuffed_animal or if this
            # is an accessory
            other_line_items = []
            if item.class.name == "StuffedAnimal"
                other_line_items = LineItem.where(stuffed_animal_id: item.id)
            else
                other_line_items = LineItem.where(accessory: item.id)
            end

            # extract an array of similar items
            similar_items = self.other_products_purchased item, other_line_items

            # take a random sampling of 1 item
            similar_items.sample(1)
        end
    end

    # method to extract all the other product purchased
    def other_products_purchased(purchased_item, other_line_items)
        similar_products = []
        other_products = []

        # extract an array of all the other purchase order ids minus this purchase order
        # that had a line item for the same purchased_item
        other_purchase_order_ids = other_line_items.collect{|line_item| line_item.purchase_order_id if line_item.purchase_order_id != self.id}.flatten.compact.uniq
        if other_purchase_order_ids.present?
            other_purchase_orders = PurchaseOrder.find other_purchase_order_ids

            # now extract all the other products purchased
            other_purchase_orders.each do |po|
                other_line_item_products = po.line_items.collect{|line_item| line_item.stuffed_animal_id.present? ? ((line_item.stuffed_animal_id != purchased_item.id) ? line_item.stuffed_animal : nil) : ((line_item.accessory_id != purchased_item.id) ? line_item.accessory : nil)}.flatten.compact
                other_products += other_line_item_products
            end
        end

        return other_products
    end
end
