local minetest = minetest

local tool = {
    "main:coalpick",
    "main:woodpick",
    "main:stonepick",
    "main:lapispick",
    "main:ironpick",
    "main:goldpick",
    "main:diamondpick",
    "main:emeraldpick",
    "main:sapphirepick",
    "main:rubypick",
}

minetest.register_node("aether:stone", {
    description = "Aether Stone",
    tiles = {"stone.png^[colorize:aqua:40"},
    groups = {stone = 1, hand = 1,pathable = 1},
    sounds = main.stoneSound(),
    drop = {
		max_items = 1,
		items= {
			{
				rarity = 0,
				tools = tool,
				items = {"aether:cobble"},
			},
			},
		},
	})
	
	
minetest.register_node("aether:cobble", {
    description = "Aether Cobblestone",
    tiles = {"cobble.png^[colorize:aqua:40"},
    groups = {stone = 1, pathable = 1},
    sounds = main.stoneSound(),
    drop = {
		max_items = 1,
		items= {
			{
				rarity = 0,
				tools = tool,
				items = {"aether:cobble"},
			},
			},
		},
})


minetest.register_node("aether:dirt", {
    description = "Aether Dirt",
    tiles = {"dirt.png^[colorize:aqua:40"},
    groups = {dirt = 1, soil=1,pathable = 1, farm_tillable=1},
    sounds = main.dirtSound(),
    paramtype = "light",
})

minetest.register_node("aether:grass", {
    description = "Aether Grass",
    tiles = {"grass.png^[colorize:aqua:40"},
    groups = {grass = 1, soil=1,pathable = 1, farm_tillable=1},
    sounds = main.dirtSound(),
    drop="aether:dirt",
})

minetest.register_node("aether:portal", {
	description = "Aether Portal",

	tiles = {
		{
			name = "aether_portal.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5,
			},
		},
		{
			name = "aether_portal.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5,
			},
		},
	},
	drawtype = "nodebox",
	paramtype = "light",
	--paramtype2 = "facedir",
	sunlight_propagates = true,
	use_texture_alpha = false,
	walkable = false,
	diggable = false,
	pointable = false,
	buildable_to = false,
	is_ground_content = false,
	drop = "",
	light_source = 7,
	--post_effect_color = {a = 180, r = 51, g = 7, b = 89},
	alpha = 140,
	node_box = {
	type = "connected",
		-- connect_top =
		-- connect_bottom =
		connect_front = {0,  -1/2, -1/2,   0,  1/2, 0 },
		connect_left =  {-1/2,   -1/2, 0, 0,   1/2,  0},
		connect_back =  {0,  -1/2,  0,   0,  1/2,  1/2 },
		connect_right = { 0,   -1/2, 0,  1/2,   1/2,  0},
	},
	connects_to = {"aether:portal","nether:glowstone"},
	groups = {unbreakable=1},
	--on_destruct = destroy_portal,
})
