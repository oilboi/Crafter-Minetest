minetest.register_plant("cactus", {
	description = "Cactus",
	
	tiles = {"cactus_top.png", "cactus_bottom.png", "cactus_side.png"},
	
	groups = {dig_immediate=1,flammable=1,touch_hurt=1},
	
	sounds = main.dirtSound(),
	
	paramtype = "light",
	
	sunlight_propagates = true,
	
	drawtype = "nodebox",
	
	buildable_to = false,
	
	waving            = 0,
	--inventory_image   = def.inventory_image,
	--walkable          = def.walkable,
	--climbable         = def.climbable,
	--paramtype2        = def.paramtype2,
	--buildable_to      = def.buildable_to,
	--selection_box     = def.selection_box,
	--drop              = def.drop,
	grows             = "up",
	node_box = {
		type = "fixed",
		fixed = {
			{-7/16, -8/16, -7/16,  7/16, 8/16,  7/16}, -- Main body
			{-8/16, -8/16, -7/16,  8/16, 8/16, -7/16}, -- Spikes
			{-8/16, -8/16,  7/16,  8/16, 8/16,  7/16}, -- Spikes
			{-7/16, -8/16, -8/16, -7/16, 8/16,  8/16}, -- Spikes
			{7/16,  -8/16,  8/16,  7/16, 8/16, -8/16}, -- Spikes
		},
	},
})

minetest.register_plant("sugarcane", {
	description = "Sugarcane",
	
	inventory_image = "sugarcane.png",
	
	tiles = {"sugarcane.png"},
	
	groups = {dig_immediate=1,flammable=1},
	
	sounds = main.grassSound(),
	
	paramtype = "light",
	
	sunlight_propagates = true,
	
	drawtype = "plantlike",
	
	buildable_to = false,
	
	waving = 1,
	
	walkable = false,
	--inventory_image   = def.inventory_image,
	--walkable          = def.walkable,
	--climbable         = def.climbable,
	--paramtype2        = def.paramtype2,
	--buildable_to      = def.buildable_to,
	--selection_box     = def.selection_box,
	--drop              = def.drop,
	grows             = "up",
	selection_box = {
		type = "fixed",
		fixed = {-7 / 16, -0.5, -7 / 16, 7 / 16, 0.5, 7 / 16}
	},
})

minetest.register_plant("grass", {
    description = "Tall Grass",
    drawtype = "plantlike",
	waving = 1,
	inventory_image = "tallgrass.png",
	walkable = false,
	climbable = false,
	paramtype = "light",
	is_ground_content = false,
    tiles = {"tallgrass.png"},
    paramtype2 = "degrotate",
    buildable_to = true,
    sunlight_propagates = true,
    groups = {dig_immediate=1,attached_node=1,flammable=1},
    sounds = main.grassSound(),
    selection_box = {
		type = "fixed",
		fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, 4 / 16, 4 / 16}
	},
	drop =  {
		max_items = 1,
		items= {
		{
			rarity = 10,
			items = {"farming:melon_seeds"},
		},
		{
			rarity = 10,
			items = {"farming:pumpkin_seeds"},
		},
		{
			rarity = 10,
			items = {"farming:wheat_seeds"},
		},
		},
	},
})

minetest.register_plant("wheat", {
	    description = "Wheat",
	    drawtype = "plantlike",
		waving = 1,
		walkable = false,
		climbable = false,
		paramtype = "light",
		is_ground_content = false,	
	    tiles = {"wheat_stage"}, --automatically adds _X.png
	    paramtype2 = "degrotate",
	    buildable_to = false,
	    groups = {leaves = 1, plant = 1, axe = 1, hand = 0,dig_immediate=1,attached_node=1,crops=1},
	    sounds = main.grassSound(),
	    sunlight_propagates = true,
	    selection_box = {
			type = "fixed",
			fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, -6 / 16, 6 / 16}
		},
		grows = "in_place",
		stages = 7,
		drop = {
			max_items = 2,
			items= {
			 {
				-- Only drop if using a tool whose name is identical to one
				-- of these.
				--rarity = 10,
				items = {"farming:wheat"},
				-- Whether all items in the dropped item list inherit the
				-- hardware coloring palette color from the dug node.
				-- Default is 'false'.
				--inherit_color = true,
			},
			{
				-- Only drop if using a tool whose name is identical to one
				-- of these.
				rarity = 2,
				items = {"farming:wheat_seeds"},
				-- Whether all items in the dropped item list inherit the
				-- hardware coloring palette color from the dug node.
				-- Default is 'false'.
				--inherit_color = true,
			},
			},
			},
		
		
		--seed definition
		--"farming:wheat_1"
		seed_name = "wheat",
		seed_description = "Wheat Seeds",
		seed_inventory_image = "wheat_seeds.png",
		seed_plants = "farming:wheat_1",
	})

minetest.register_plant("melon_stem", {
	    description = "Melon Stem",
	    drawtype = "plantlike",
		waving = 1,
		walkable = false,
		climbable = false,
		paramtype = "light",
		sunlight_propagates = true,
		is_ground_content = false,	
	    tiles = {"melon_stage"}, --automatically adds _X.png
	    buildable_to = false,
	    groups = {leaves = 1,plant=1, stem = 1, axe = 1, hand = 0,dig_immediate=1,attached_node=1,crops=1},
	    sounds = main.grassSound(),
	    selection_box = {
			type = "fixed",
			fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, -6 / 16, 6 / 16}
		},
		grows = "in_place_yields",
		grown_node="farming:melon",
		stages = 7,
		--stem stage complete definition (fully grown and budding)
		stem_description = "",
		stem_tiles = {"nothing.png","nothing.png","melon_stage_complete.png^[transformFX","melon_stage_complete.png","nothing.png","nothing.png",},
		stem_drawtype = "nodebox",
		stem_walkable = false,
		stem_sunlight_propagates = true,
		stem_paramtype = "light",
		stem_node_box = {
			type = "fixed",
			fixed = {
				{-0/16, -8/16, -7/16,  0/16, 8/16,  7/16}
			},
		},
		stem_selection_box = {
			type = "fixed",
			fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, -6 / 16, 6 / 16}
		},
		stem_drop = {
			max_items = 2,
			items= {
			{
				items = {"farming:melon_seeds"},
			},
			{
				rarity = 2,
				items = {"farming:melon_seeds"},
			},
			},
		},
	    stem_groups = {plant=1,dig_immediate=1,attached_node=1,crops=1},
	    stem_sounds = main.woodSound(),
	    
	    --fruit definition (what the stem creates)
	    fruit_name        = "melon",
	    fruit_description = "Melon",
	    fruit_tiles = {"melon_top.png","melon_top.png","melon_side.png","melon_side.png","melon_side.png","melon_side.png"},
	    fruit_groups = {pathable = 1,wood=1,flammable=1},
	    fruit_sounds = main.woodSound(),
	    fruit_drop  = {
			max_items = 6,
			items= {
				{
					items = {"farming:melon_slice"},
				},
				{
					items = {"farming:melon_slice"},
				},
				{
					items = {"farming:melon_slice"},
				},
				{
					items = {"farming:melon_slice"},
				},
				{
					rarity = 5,
					items = {"farming:melon_slice"},
				},
				{
					rarity = 15,
					items = {"farming:melon_seeds"},
				},
			},
		},
		
		--seed definition
		--"farming:wheat_1"
		seed_name = "melon",
		seed_description = "Melon Seeds",
		seed_inventory_image = "melon_seeds.png",
		seed_plants = "farming:melon_stem_1",
})
minetest.register_craftitem("farming:melon_slice", {
	description = "Melon Slice",
	inventory_image = "melon_slice.png",
	groups = {satiation=1,hunger=2},
})



minetest.register_plant("pumpkin_stem", {
	    description = "Pumpkin Stem",
	    drawtype = "plantlike",
		waving = 1,
		walkable = false,
		climbable = false,
		paramtype = "light",
		sunlight_propagates = true,
		is_ground_content = false,	
	    tiles = {"melon_stage"}, --automatically adds _X.png
	    buildable_to = false,
	    groups = {leaves = 1,plant=1, stem = 1, axe = 1, hand = 0,dig_immediate=1,attached_node=1,crops=1},
	    sounds = main.grassSound(),
	    selection_box = {
			type = "fixed",
			fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, -6 / 16, 6 / 16}
		},
		grows = "in_place_yields",
		grown_node="farming:pumpkin",
		stages = 7,
		
		--stem stage complete definition (fully grown and budding)
		stem_description = "",
		stem_tiles = {"nothing.png","nothing.png","melon_stage_complete.png^[transformFX","melon_stage_complete.png","nothing.png","nothing.png",},
		stem_drawtype = "nodebox",
		stem_walkable = false,
		stem_sunlight_propagates = true,
		stem_paramtype = "light",
		stem_node_box = {
			type = "fixed",
			fixed = {
				{-0/16, -8/16, -7/16,  0/16, 8/16,  7/16}
			},
		},
		stem_selection_box = {
			type = "fixed",
			fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, -6 / 16, 6 / 16}
		},
		stem_drop = {
			max_items = 2,
			items= {
			{
				items = {"farming:pumpkin_seeds"},
			},
			{
				rarity = 2,
				items = {"farming:pumpkin_seeds"},
			},
			},
		},
	    stem_groups = {plant=1,dig_immediate=1,attached_node=1,crops=1},
	    stem_sounds = main.woodSound(),
	    
	    --fruit definition (what the stem creates)
	    fruit_name        = "pumpkin",
	    fruit_description = "Pumpkin",
	    fruit_tiles = {"pumpkin_top.png","pumpkin_top.png","pumpkin_side.png","pumpkin_side.png","pumpkin_side.png","pumpkin_side.png"},
	    fruit_groups = {pathable = 1,wood=1,flammable=1},
	    fruit_sounds = main.woodSound(),
		--seed definition
		--"farming:wheat_1"
		seed_name = "pumpkin",
		seed_description = "Pumpkin Seeds",
		seed_inventory_image = "pumpkin_seeds.png",
		seed_plants = "farming:pumpkin_stem_1",
})

minetest.register_craft({
	type = "shapeless",
	output = "farming:pumpkin_seeds",
	recipe = {"farming:pumpkin"},
})
minetest.register_craft({
	type = "fuel",
	recipe = "farming:pumpkin",
	burntime = 3,
})
minetest.register_craft({
	type = "cooking",
	output = "farming:pumpkin_pie",
	recipe = "farming:pumpkin",
	cooktime = 2,
})
minetest.register_craftitem("farming:pumpkin_pie", {
	description = "Pumpkin Pie",
	inventory_image = "pumpkin_pie.png",
	groups = {satiation=4,hunger=3},
})


minetest.register_decoration({
	name = "farming:sugarcane",
	deco_type = "simple",
	place_on = {"main:dirt","main:grass","main:sand"},
	sidelen = 16,
	noise_params = {
		offset = -0.3,
		scale = 0.7,
		spread = {x = 100, y = 100, z = 100},
		seed = 354,
		octaves = 3,
		persist = 0.7
	},
	y_max = 1,
	y_min = 1,
	decoration = "farming:sugarcane",
	height = 2,
	height_max = 5,
	spawn_by = "main:water",
	num_spawn_by = 1,
})


minetest.register_decoration({
		name = "farming:cactus",
		deco_type = "simple",
		place_on = {"main:sand"},
		sidelen = 16,
		noise_params = {
			offset = -0.012,
			scale = 0.024,
			spread = {x = 100, y = 100, z = 100},
			seed = 230,
			octaves = 3,
			persist = 0.6
		},
		y_max = 30,
		y_min = 0,
		decoration = "farming:cactus",
		height = 3,
		height_max = 4,
	})


minetest.register_decoration({
	deco_type = "simple",
	place_on = "main:grass",
	sidelen = 16,
	fill_ratio = 0.5,
	--biomes = {"grassland"},
	decoration = "farming:grass",
	height = 1,
})	
