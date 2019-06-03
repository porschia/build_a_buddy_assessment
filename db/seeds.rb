require 'roo'
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

# first extract the excel data using roo
build_a_buddy_spreadsheet = Roo::Excelx.new('data/Build a Buddy Data.xlsx')

# extract the individual sheets before importing the data
inventory_sheet = build_a_buddy_spreadsheet.sheet("Inventory")
product_prices_sheet = build_a_buddy_spreadsheet.sheet("Product Prices")
accessory_compatibility_sheet = build_a_buddy_spreadsheet.sheet("Accessory Compatibility")
purchase_orders_sheet = build_a_buddy_spreadsheet.sheet("Purchase Orders")

# extract and import the inventory_sheet data
# iterate over the rows, skipping the first 2 rows because those are headers

# notify the developer that the inventories are being imported
puts "Beginning Inventory Setup"
((inventory_sheet.first_row + 2)..inventory_sheet.last_row).each do |i|
    begin
        row = inventory_sheet.row(i)
        # create a stuffed_animal if there is data present in the row
        # we're making an opiniated decision that all data for the stuffed_animal
        # must be present in order to create a record from the spreadsheet
        if row[0].present? and row[1].present?
            stuffed_animal = StuffedAnimal.create(description: row[0], quantity: row[1])
        end

        # create an accessory if there is data present in the row
        # we're making an opiniated decision that all data for the accessory must
        # be present in order to create a record from the spreadsheet
        if row[3].present? and row[4].present? and row[5].present?
            accessory = Accessory.create(description: row[3], size: row[4], quantity: row[5])
        end
    rescue Exception => e
        puts "there was an error setting up the inventory"
        puts e.message
        puts e.backtrace
    end
end

# extract and import the product_prices_sheet
# iterate over the rows, skipping the first 2 rows because those are headers

# notify the developer that the inventories are being imported
puts "Beginning Product Prices Setup"
((product_prices_sheet.first_row + 2)..product_prices_sheet.last_row).each do |i|
    begin
        row = product_prices_sheet.row(i)

        # update the stuffed_animal with product pricing if the stuffed_animal exists
        if row[0].present? and row[1].present? and row[2].present?
            # there should only be 1 stuffed_animal with each description
            stuffed_animal = StuffedAnimal.find_by(description: row[0])

            # if a stuffed_animal was found, update the record with pricing informaiton
            if stuffed_animal.present?
                stuffed_animal.update_attributes(cost: row[1], sale_price: row[2])
            end
        end

        # update the accessory with product pricing if the accessory exists
        if row[4].present? and row[5].present? and row[6].present? and row[7].present?
            # there should only be 1 accessory with each description/size combo
            accessory = Accessory.find_by(description: row[4], size: row[5])

            if accessory.present?
                accessory.update_attributes(cost: row[6], sale_price: row[7])
            end
        end

    rescue Exception => e
        puts "there was an error setting up the product prices"
        puts e.message
        puts e.backtrace
    end
end
