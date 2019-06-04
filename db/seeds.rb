require 'roo'
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

# first extract the excel data using roo
build_a_buddy_spreadsheet = Roo::Excelx.new('data/Build a Buddy Data.xlsx')

# extract and import the build_a_buddy_spreadsheet.sheet("Inventory") data
# iterate over the rows, skipping the first 2 rows because those are headers

# notify the developer that the inventories are being imported
puts "Beginning Inventory Setup"
((build_a_buddy_spreadsheet.sheet("Inventory").first_row + 2)..build_a_buddy_spreadsheet.sheet("Inventory").last_row).each do |i|
    begin
        row = build_a_buddy_spreadsheet.sheet("Inventory").row(i)
        # create a stuffed_animal if there is data present in the row
        # we're making an opiniated decision that all data for the stuffed_animal
        # must be present in order to create a record from the spreadsheet
        if row[0].present? and row[1].present?
            puts "Creating a #{row[0]} Stuffed Animal"
            stuffed_animal = StuffedAnimal.create(description: row[0], quantity: row[1])
        end

        # create an accessory if there is data present in the row
        # we're making an opiniated decision that all data for the accessory must
        # be present in order to create a record from the spreadsheet
        if row[3].present? and row[4].present? and row[5].present?
            puts "Creating a #{row[4]} #{row[3]} Accessory"
            accessory = Accessory.create(description: row[3], size: row[4], quantity: row[5])
        end
    rescue Exception => e
        puts "there was an error setting up the inventory"
        puts e.message
        puts e.backtrace
    end
end

# extract and import the build_a_buddy_spreadsheet.sheet("Product Prices") sheet
# iterate over the rows, skipping the first 2 rows because those are headers

# notify the developer that the product prices are being set up
puts "Beginning Product Prices Setup"
((build_a_buddy_spreadsheet.sheet("Product Prices").first_row + 2)..build_a_buddy_spreadsheet.sheet("Product Prices").last_row).each do |i|
    begin
        row = build_a_buddy_spreadsheet.sheet("Product Prices").row(i)

        # update the stuffed_animal with product pricing if the stuffed_animal exists
        if row[0].present? and row[1].present? and row[2].present?
            # there should only be 1 stuffed_animal with each description
            stuffed_animal = StuffedAnimal.find_by(description: row[0])

            # if a stuffed_animal was found, update the record with pricing informaiton
            if stuffed_animal.present?
                "Updating the #{row[0]} Stuffed Animal"
                stuffed_animal.update_attributes(cost: row[1], sale_price: row[2])
            end
        end

        # update the accessory with product pricing if the accessory exists
        if row[4].present? and row[5].present? and row[6].present? and row[7].present?
            # there should only be 1 accessory with each description/size combo
            accessory = Accessory.find_by(description: row[4], size: row[5])

            if accessory.present?
                "Updating the #{row[5]} #{row[4]} Accessory"
                accessory.update_attributes(cost: row[6], sale_price: row[7])
            end
        end

    rescue Exception => e
        puts "there was an error setting up the product prices"
        puts e.message
        puts e.backtrace
    end
end

# extract and import the build_a_buddy_spreadsheet.sheet("Accessory Compatibility") sheet
# iterate over the rows, skipping the first 2 rows because those are headers

# notify the developer that the accessory compatibilities are being set up
puts "Beginning Accessory Compatibility Setup"
((build_a_buddy_spreadsheet.sheet("Accessory Compatibility").first_row + 2)..build_a_buddy_spreadsheet.sheet("Accessory Compatibility").last_row).each do |i|
    begin
        row = build_a_buddy_spreadsheet.sheet("Accessory Compatibility").row(i)

        # find the stuffed_animal that this row is associated with
        stuffed_animal = StuffedAnimal.find_by(description: row[0])

        # if there is a stuffed animal, continue extracting the accessories
        if stuffed_animal.present?
            accessories = []
            shoe = nil
            shirt = nil
            tiara = nil
            glasses = nil
            # TECHNICAL DEBT: the header should be used to find the accessories,
            # if there's enough time after the other sections, I'll come back and
            # try to optimize this
            # if there is a value in rows 2 and 3, those are small shoes and shirts
            # NOTE: we know by looking at the spreadsheet that there is never an
            # instance of shoe size being different from shirt size so we're going
            # to bully the spreadsheet to make the import work, not the best thing
            if row[1].present? and row[2].present?
                shoe = Accessory.find_by(description: "Shoes", size: "small")
                shirt = Accessory.find_by(description: "T-Shirt", size: "small")
            elsif row[3].present? and row[4].present?
                shoe = Accessory.find_by(description: "Shoes", size: "medium")
                shirt = Accessory.find_by(description: "T-Shirt", size: "medium")
            elsif row[5].present? and row[6].present?
                shoe = Accessory.find_by(description: "Shoes", size: "large")
                shirt = Accessory.find_by(description: "T-Shirt", size: "large")
            end

            # now find a tiara and glasses if those are selected in the spreadsheet
            if row[7].present?
                tiara = Accessory.find_by(description: "Tiara", size: "All")
            end

            if row[8].present?
                glasses = Accessory.find_by(description: "Glasses", size: "All")
            end

            accessories << shoe if shoe.present?
            accessories << shirt if shirt.present?
            accessories << tiara if tiara.present?
            accessories << glasses if glasses.present?

            # if there is a shoe create the accessory_compatibility that links the
            # stuffed_animal and the shoe
            accessories.each do |animal_accessory|
                accessory_compatibility = AccessoryCompatibility.new
                accessory_compatibility.stuffed_animal = stuffed_animal
                accessory_compatibility.accessory = animal_accessory
                accessory_compatibility.save
            end
        end

    rescue Exception => e
        puts "there was an error setting up the accessory compatibilites"
        puts e.message
        puts e.backtrace
    end
end

# extract and import the build_a_buddy_spreadsheet.sheet("Purchase Orders") sheet
# iterate over the rows, skipping the first 2 rows because those are headers

# notify the developer that the purchase orders are being set up
puts "Beginning Purchase Order Setup"
first_headers = build_a_buddy_spreadsheet.sheet("Purchase Orders").row(1)[2..-1]
second_headers = build_a_buddy_spreadsheet.sheet("Purchase Orders").row(2)[2..-1]
((build_a_buddy_spreadsheet.sheet("Purchase Orders").first_row + 2)..build_a_buddy_spreadsheet.sheet("Purchase Orders").last_row).each do |i|
    begin
        row = build_a_buddy_spreadsheet.sheet("Purchase Orders").row(i)
        po = nil

        # first create a purchase order with the first 2 cells information
        if row[0].present? and row[1].present?
            po = PurchaseOrder.create(date: row[0], time: row[1])
        end

        # if there's a valid po, continue processing the row
        if po.present?

            # now loop through the rest of the rows and find the accessory or stuffed_animal
            # that has been added and create a line item for each
            row[2..-1].each_with_index do |row_content, i|
                # if the row_content is greater than 0 that means a line_item
                # needs to be created from it
                if row_content > 0
                    # if the index is between 0-3 then then this is for a stuffed_animal
                    if i < 4
                        stuffed_animal = StuffedAnimal.find_by(description: second_headers[i])
                        if stuffed_animal.present?
                            line_item = LineItem.new
                            line_item.purchase_order = po
                            line_item.stuffed_animal = stuffed_animal
                            line_item.save
                        end
                    else
                        # first headers looks like this ["Stuffed Animal", nil, nil, nil, "Small", nil, "Medium", nil, "Large", nil, "All", nil]
                        # so if the size is nil when searching for first_headers[i], try first_headers[i -1]
                        size = first_headers[i]
                        size = first_headers[i -1] if size.nil?
                        accessory = Accessory.find_by(size: size, description: second_headers[i])

                        # some of the sizes are lowercase, so if no accessory is found, try downcasing
                        # size and searching again
                        if accessory.blank?
                            accessory = Accessory.find_by(size: size.downcase, description: second_headers[i])
                        end

                        if accessory.present?
                            line_item = LineItem.new
                            line_item.purchase_order = po
                            line_item.accessory = accessory
                            line_item.save
                        end
                    end
                end
            end
        end
    rescue Exception => e
        puts "there was an error setting up the purchase orders"
        puts e.message
        puts e.backtrace
    end
end
