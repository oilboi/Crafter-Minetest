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
			items = {"farming:seeds"},
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
	    grow_stage = i,
	    groups = {leaves = 1, plant = 1, axe = 1, hand = 0,dig_immediate=1,attached_node=1,crops=1},
	    sounds = main.grassSound(),
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
				items = {"farming:seeds"},
				-- Whether all items in the dropped item list inherit the
				-- hardware coloring palette color from the dug node.
				-- Default is 'false'.
				--inherit_color = true,
			},
			},
			},
	})
minetest.register_plant("melon_stem", {
	    description = "Melon Stem",
	    drawtype = "plantlike",
		waving = 1,
		walkable = false,
		climbable = false,
		paramtype = "light",
		is_ground_content = false,	
	    tiles = {"melon_stage"}, --automatically adds _X.png
	    paramtype2 = "degrotate",
	    buildable_to = false,
	    grow_stage = i,
	    groups = {leaves = 1, plant = 1, axe = 1, hand = 0,dig_immediate=1,attached_node=1,crops=1},
	    sounds = main.grassSound(),
	    selection_box = {
			type = "fixed",
			fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, -6 / 16, 6 / 16}
		},
		grows = "in_place_yields",
		grown_node="farming:melon",
		grown_replacer = "farming:melon_stem_stage_complete",
		stages = 7,
		drop = {
			max_items = 2,
			items= {
			 {
				-- Only drop if using a tool whose name is identical to one
				-- of these.
				--rarity = 10,
				items = {"farming:seeds"},
				-- Whether all items in the dropped item list inherit the
				-- hardware coloring palette color from the dug node.
				-- Default is 'false'.
				--inherit_color = true,
			},
			{
				-- Only drop if using a tool whose name is identical to one
				-- of these.
				rarity = 2,
				items = {"farming:seeds"},
				-- Whether all items in the dropped item list inherit the
				-- hardware coloring palette color from the dug node.
				-- Default is 'false'.
				--inherit_color = true,
			},
			},
			},
	})


minetest.register_node("farming:melon", {
    description = "Melon",
    tiles = {"melon_top.png","melon_top.png","melon_side.png","melon_side.png","melon_side.png","melon_side.png"},
    paramtype2 = "facedir",
    groups = {wood = 1, pathable = 1,flammable=1},
    sounds = main.woodSound(),
    after_destruct = function(pos,oldnode)
	    local facedir = oldnode.param2
	    facedir = minetest.facedir_to_dir(facedir)
	    local dir = vector.multiply(facedir,-1)
	    
	    minetest.set_node(vector.add(dir,pos), {name = "farming:melon_stem_1"})
    end
})

minetest.register_node("farming:melon_stem_stage_complete", {
    description = "",
    tiles = {"nothing.png","nothing.png","melon_stage_complete.png^[transformFX","melon_stage_complete.png","nothing.png","nothing.png",},
    drawtype = "nodebox",
    node_box = {
		type = "fixed",
		fixed = {
			{-0/16, -8/16, -7/16,  0/16, 8/16,  7/16}, -- Main body
		},
	},
    paramtype2 = "facedir",
    groups = {wood = 1, pathable = 1,flammable=1},
    sounds = main.woodSound(),
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
