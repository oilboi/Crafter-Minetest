--create on and off redstone ore
for i = 0,1 do
	local light_level = i * 9
	local groups
	local on_punch = nil
	if i == 0 then
		groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,pathable = 1}
		on_punch = function(pos, node, puncher, pointed_thing)
			minetest.set_node(pos, {name="redstone:ore_1"})
			redstone.collect_info(pos)
			local timer = minetest.get_node_timer(pos)
			timer:start(math.random(10,50))
		end
	else
		groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,pathable = 1,redstone=1,redstone_torch=1,redstone_power=9}
		on_timer = function(pos, elapsed)
			minetest.set_node(pos, {name="redstone:ore_0"})
			redstone.collect_info(pos)
		end
	end
	minetest.register_node("redstone:ore_"..i, {
		description = "Redstone Ore",
		tiles = {"redstone_ore.png"},
		groups = groups,
		sounds = main.stoneSound(),
		light_source = light_level,
		drop = {
			max_items = 5,
			items= {
				{
					--rarity = 0,
					tools = {"main:ironpick","main:goldpick","main:diamondpick"},
					items = {"redstone:dust"},
				},
				{
					--rarity = 0,
					tools = {"main:ironpick","main:goldpick","main:diamondpick"},
					items = {"redstone:dust"},
				},
				{
					--rarity = 0,
					tools = {"main:ironpick","main:goldpick","main:diamondpick"},
					items = {"redstone:dust"},
				},
				{
					--rarity = 0,
					tools = {"main:ironpick","main:goldpick","main:diamondpick"},
					items = {"redstone:dust"},
				},
				{
					rarity = 5,
					tools = {"main:ironpick","main:goldpick","main:diamondpick"},
					items = {"redstone:dust"},
				},
			},
		},
		on_punch = on_punch,
		on_timer = on_timer,
	})
end
--redstone ore
minetest.register_ore({
	ore_type	 = "scatter",
	ore		= "redstone:ore_0",
	wherein	  = "main:stone",
	clust_scarcity = 14 * 14 * 14,
	clust_num_ores = 10,
	clust_size     = 3,
	y_max	    = 31000,
	y_min	    = 1025,
})

minetest.register_ore({
	ore_type	 = "scatter",
	ore		= "redstone:ore_0",
	wherein	  = "main:stone",
	clust_scarcity = 8 * 8 * 8,
	clust_num_ores = 8,
	clust_size     = 5,
	y_max	    = -128,
	y_min	    = -31000,
})

minetest.register_ore({
	ore_type	 = "scatter",
	ore		= "redstone:ore_0",
	wherein	  = "main:stone",
	clust_scarcity = 8 * 8 * 8,
	clust_num_ores = 8,
	clust_size     = 5,
	y_max	    = -256,
	y_min	    = -31000,
})
