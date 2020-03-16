minetest.register_node("main:"..ore.."ore", {
	description = ore:gsub("^%l", string.upper).." Ore",
	tiles = {"stone.png^redstoneore.png"},
	groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,pathable = 1},
	sounds = main.stoneSound(),
	light_source = 8,--debugging ore spawn
	drop = {
		max_items = 1,
		items= {
			{
				rarity = 0,
				tools = tool_required,
				items = drops,
			},
		},
	},
})

minetest.register_ore({
	ore_type	 = "scatter",
	ore		= "main:goldore",
	wherein	  = "main:stone",
	clust_scarcity = 13 * 13 * 13,
	clust_num_ores = 5,
	clust_size     = 3,
	y_max	    = -128,
	y_min	    = -31000,
})

-- Mese crystal

minetest.register_ore({
	ore_type	 = "scatter",
	ore		= "main:diamondore",
	wherein	  = "main:stone",
	clust_scarcity = 14 * 14 * 14,
	clust_num_ores = 5,
	clust_size     = 3,
	y_max	    = 31000,
	y_min	    = 1025,
})

minetest.register_ore({
	ore_type	 = "scatter",
	ore		= "main:diamondore",
	wherein	  = "main:stone",
	clust_scarcity = 18 * 18 * 18,
	clust_num_ores = 3,
	clust_size     = 2,
	y_max	    = -128,
	y_min	    = -1023,
})

minetest.register_ore({
	ore_type	 = "scatter",
	ore		= "main:diamondore",
	wherein	  = "main:stone",
	clust_scarcity = 14 * 14 * 14,
	clust_num_ores = 5,
	clust_size     = 3,
	y_max	    = -128,
	y_min	    = -31000,
})
