local path = minetest.get_modpath("farming")
dofile(path.."/plant_api.lua")
dofile(path.."/registers.lua")
dofile(path.."/tools.lua")
dofile(path.."/soil.lua")


minetest.register_craftitem("farming:wheat", {
	description = "Wheat",
	inventory_image = "wheat_harvested.png",
})


minetest.register_craftitem("farming:bread", {
	description = "Bread",
	inventory_image = "bread.png",
	groups = {satiation=3,hunger=3},
})

minetest.register_craftitem("farming:toast", {
	description = "Toast",
	inventory_image = "bread.png^[colorize:black:100",
	groups = {satiation=4,hunger=4},
})

minetest.register_craft({
	output = "farming:bread",
	recipe = {
		{"farming:wheat", "farming:wheat", "farming:wheat"}
	}
})


minetest.register_craft({
	type = "cooking",
	output = "farming:toast",
	recipe = "farming:bread",
	cooktime = 3,
})
