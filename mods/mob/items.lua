--items
minetest.register_craftitem("mob:raw_porkchop", {
	description = "Raw Porkchop",
	inventory_image = "raw_porkchop.png",
})
minetest.register_craftitem("mob:cooked_porkchop", {
	description = "Cooked Porkchop",
	inventory_image = "cooked_porkchop.png",
})

--cooking
minetest.register_craft({
	type = "cooking",
	output = "mob:cooked_porkchop",
	recipe = "mob:raw_porkchop",
	cooktime = 3,
})
