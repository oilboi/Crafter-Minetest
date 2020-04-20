
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
    groups = {netherrack = 1, pathable = 1},
    sounds = main.stoneSound(),
    is_ground_content = false,
    light_source = 7,
    drop = {
			max_items = 1,
			items= {
				{
					rarity = 0,
					tools = {"main:woodpick","main:stonepick","main:ironpick","main:goldpick","main:diamondpick"},
					items = {"nether:netherrack"},
				},
				},
			},
})


minetest.register_node("nether:obsidian", {
    description = "Obsidian",
    tiles = {"obsidian.png"},
    groups = {stone = 5, pathable = 1},
    --groups = {stone = 1, pathable = 1}, --leave this here for debug
    sounds = main.stoneSound(),
    is_ground_content = false,
    after_destruct = function(pos, oldnode)
		destroy_nether_portal(pos)
    end,
    --light_source = 7,
})


minetest.register_node("nether:lava", {
	description = "Lava",
	drawtype = "liquid",
	tiles = {
		{
			name = "lava_source.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
		{
			name = "lava_source.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	paramtype = "light",
	light_source = 13,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "nether:lavaflow",
	liquid_alternative_source = "nether:lava",
	liquid_viscosity = 1,
	liquid_renewable = true,
	damage_per_second = 4 * 2,
	post_effect_color = {a = 191, r = 255, g = 64, b = 0},
	groups = {lava = 3, liquid = 2, igniter = 1},
})

minetest.register_node("nether:lavaflow", {
	description = "Flowing Lava",
	drawtype = "flowingliquid",
	tiles = {"lava_flow.png"},
	special_tiles = {
		{
			name = "lava_flow.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.3,
			},
		},
		{
			name = "lava_flow.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.3,
			},
		},
	},
	selection_box = {
            type = "fixed",
            fixed = {
                {0, 0, 0, 0, 0, 0},
            },
        },
	paramtype = "light",
	paramtype2 = "flowingliquid",
	light_source = 13,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "nether:lavaflow",
	liquid_alternative_source = "nether:lava",
	liquid_viscosity = 1,
	liquid_renewable = true,
	damage_per_second = 2,
	post_effect_color = {a = 191, r = 255, g = 64, b = 0},
	groups = {lava = 3, liquid = 2, igniter = 1},
})
