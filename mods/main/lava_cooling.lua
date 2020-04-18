minetest.register_abm({
	label = "Lava cooling",
	nodenames = {"main:lava"},
	neighbors = {"main:water", "main:waterflow"},
	interval = 1.0,
	chance = 5.0,
	catch_up = false,
	action = function(pos)
		minetest.set_node(pos,{name="nether:obsidian"})
	end,
})
minetest.register_abm({
	label = "Lava cooling",
	nodenames = {"main:lavaflow"},
	neighbors = {"main:water", "main:waterflow"},
	interval = 1.0,
	chance = 5.0,
	catch_up = false,
	action = function(pos)
		minetest.set_node(pos,{name="main:cobble"})
	end,
})
