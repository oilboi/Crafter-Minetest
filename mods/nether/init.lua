minetest.register_biome({
	name = "Hell",
	node_top = "air",
	depth_top = 1,
	node_filler = "air",
	depth_filler = 10,
	node_riverbed = "air",
	depth_riverbed = 10,
	node_stone = "nether:netherrack",
	node_water = "air",
	--node_dungeon = "default:cobble",
	--node_dungeon_alt = "default:mossycobble",
	--node_dungeon_stair = "stairs:stair_cobble",
	vertical_blend = 0,
	y_max = -10035,
	y_min = -20000,
	heat_point = 0,
	humidity_point = 0,
})

minetest.register_biome({
	name = "Boundary of Hell",
	node_top = "nether:bedrock",
	depth_top = 1,
	node_filler = "nether:bedrock",
	depth_filler = 1,
	node_riverbed = "nether:bedrock",
	depth_riverbed = 1,
	node_stone = "nether:bedrock",
	node_water = "nether:bedrock",
	node_cave_liquid  = "nether:bedrock",
	node_dungeon = "nether:bedrock",
	node_dungeon_alt = "nether:bedrock",
	node_dungeon_stair = "nether:bedrock",
	vertical_blend = 0,
	y_max = -10033,
	y_min = -10034,
	heat_point = -100,
	humidity_point = -100,
})

minetest.register_node("nether:bedrock", {
    description = "Bedrock",
    tiles = {"bedrock.png"},
    groups = {unbreakable = 1, pathable = 1},
    sounds = main.stoneSound(),
    is_ground_content = false,
    --light_source = 14, --debugging
})


minetest.register_node("nether:netherrack", {
    description = "Netherrack",
    tiles = {"netherrack.png"},
    groups = {stone = 1, pathable = 1},
    sounds = main.stoneSound(),
    is_ground_content = false,
    light_source = 7,
})
