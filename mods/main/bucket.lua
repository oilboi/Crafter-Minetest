-- Item definitions
minetest.register_craftitem("main:bucket", {
      description = "Bucket",
      inventory_image = "bucket.png",
      --wield_image = "bucket.png",
      liquids_pointable = true,
      on_place = function(itemstack, placer, pointed_thing)
            --set it to water
            if minetest.get_node(pointed_thing.under).name == "main:water" then
                  itemstack:replace(ItemStack("main:bucket_water"))
                  minetest.remove_node(pointed_thing.under)
                  return(itemstack)
            end
      end
})


minetest.register_craftitem("main:bucket_water", {
      description = "Bucket with Water",
      inventory_image = "bucket_water.png",
      --wield_image = "bucket.png",
      liquids_pointable = true,
      on_place = function(itemstack, placer, pointed_thing)
            --set it to water
            if minetest.get_node(pointed_thing.above).name == "air" then
                  itemstack:replace(ItemStack("main:bucket"))
                  minetest.set_node(pointed_thing.above,{name="main:water"})
                  return(itemstack)
            end
      end
})
