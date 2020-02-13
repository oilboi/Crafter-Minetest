--[[
depth = initial level found
]]--

	
--coal
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "main:coalore",
	wherein        = "main:stone",
	clust_scarcity = 13 * 13 * 13,
	clust_num_ores = 5,
	clust_size     = 3,
	y_max          = 32,
	y_min          = -64,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "main:coalore",
	wherein        = "main:stone",
	clust_scarcity = 13 * 13 * 13,
	clust_num_ores = 7,
	clust_size     = 3,
	y_max          = -64,
	y_min          = -128,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "main:coalore",
	wherein        = "main:stone",
	clust_scarcity = 13 * 13 * 13,
	clust_num_ores = 9,
	clust_size     = 5,
	y_max          = -128,
	y_min          = -31000,
})


--iron
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "main:ironore",
	wherein        = "main:stone",
	clust_scarcity = 13 * 13 * 13,
	clust_num_ores = 5,
	clust_size     = 3,
	y_max          = 32,
	y_min          = -64,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "main:ironore",
	wherein        = "main:stone",
	clust_scarcity = 15 * 15 * 15,
	clust_num_ores = 7,
	clust_size     = 3,
	y_max          = -32,
	y_min          = -128,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "main:ironore",
	wherein        = "main:stone",
	clust_scarcity = 13 * 13 * 13,
	clust_num_ores = 9,
	clust_size     = 5,
	y_max          = -128,
	y_min          = -31000,
})


--gold
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "main:goldore",
	wherein        = "main:stone",
	clust_scarcity = 15 * 15 * 15,
	clust_num_ores = 7,
	clust_size     = 3,
	y_max          = -128,
	y_min          = -256,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "main:goldore",
	wherein        = "main:stone",
	clust_scarcity = 13 * 13 * 13,
	clust_num_ores = 9,
	clust_size     = 5,
	y_max          = -256,
	y_min          = -31000,
})

--diamond
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "main:diamondore",
	wherein        = "main:stone",
	clust_scarcity = 15 * 15 * 15,
	clust_num_ores = 7,
	clust_size     = 3,
	y_max          = -256,
	y_min          = -328,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "main:diamondore",
	wherein        = "main:stone",
	clust_scarcity = 13 * 13 * 13,
	clust_num_ores = 9,
	clust_size     = 5,
	y_max          = -328,
	y_min          = -31000,
})
