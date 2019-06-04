class StuffedAnimal < ApplicationRecord
    has_many :accessory_compatibilities
    has_many :line_items
    has_many :accessories, through: :accessory_compatibilities
    has_many :purchase_orders, through: :line_items

    # method to determine best build options based on price
    # the winning builds are returned with the format
    # [{"animal_1_id accessory_1_id": revenue}, {"animal_4_id": revenue}, {"animal_2_id accessory_1_id accessory_3_id": revenue}]
    # it is expected that the controller making this request would extract the returned data
    # and put together the stuffed_animal/accessories using a .split(" "), where the first id will always be
    # the stuffed_animal and all subsequent ids will be the accessories
    def self.best_build_options_for_price price
        # first extract all stuffed_animals under the price passed in
        stuffed_animals = StuffedAnimal.where("sale_price" < "?", price)
        valid_builds = []
        stuffed_animals.each do |stuffed_animal|
            animal_price = stuffed_animal.sale_price
            animal_build = {}
            animal_build["#{stuffed_animal.id}"] = (stuffed_animal.sale_price - stuffed_animal.cost).round(2)
            valid_builds << animal_build

            # now start adding valid accessories to the animal to see if any of
            # those builds are valid
            valid_accessories = stuffed_animal.accessories.select{|accessory| (accessory.sale_price + animal_price) <= price}
            valid_accessories.each do |accessory|
                accessory_build = {}
                accessory_build["#{stuffed_animal.id} #{accessory.id}"] = (accessory.sale_price - accessory.cost) + (stuffed_animal.sale_price - stuffed_animal.cost)

                # TODO: need to also check for combinations of accessories with the stuffed_animal but running
                # out of time
            end
        end

        top_builds = valid_builds.sort_by{|id, revenue| revenue.desc}.limit(3)

    end
end
