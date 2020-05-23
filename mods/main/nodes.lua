--ore def with required tool
local ores = {"coal","iron","gold","diamond"}
local tool = {"main:woodpick","main:stonepick","main:ironpick","main:goldpick","main:diamondpick"}
for id,ore in pairs(ores) do
	local tool_required = {}
	for i = id,5 do
		table.insert(tool_required, tool[i])
	end

	local drops = {"main:"..ore.."ore"}
	if ore == "diamond" then drops = {"main:diamond"} elseif ore == "coal" then drops = {"main:coal"} end
	
	minetest.register_node("main:"..ore.."ore", {
		description = ore:gsub("^%l", string.upper).." Ore",
		tiles = {"stone.png^"..ore.."ore.png"},
		groups = {stone = id, pathable = 1,experience=id},
		sounds = main.stoneSound(),
		--light_source = 14,--debugging ore spawn
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
end

minetest.register_node("main:stone", {
    description = "Stone",
    tiles = {"stone.png"},
    groups = {stone = 1, hand = 1,pathable = 1},
    sounds = main.stoneSound(),
    drop = {
		max_items = 1,
		items= {
			{
				rarity = 0,
				tools = tool,
				items = {"main:cobble"},
			},
			},
		},
	})

minetest.register_node("main:cobble", {
    description = "Cobblestone",
    tiles = {"cobble.png"},
    groups = {stone = 1, pathable = 1},
    sounds = main.stoneSound(),
    drop = {
		max_items = 1,
		items= {
			{
				rarity = 0,
				tools = tool,
				items = {"main:cobble"},
			},
			},
		},
})

minetest.register_node("main:mossy_cobble", {
    description = "Mossy Cobblestone",
    tiles = {"mossy_cobble.png"},
    groups = {stone = 1, pathable = 1},
    sounds = main.stoneSound(),
    drop = {
		max_items = 1,
		items= {
			{
				rarity = 0,
				tools = tool,
				items = {"main:mossy_cobble"},
			},
			},
		},
})

minetest.register_node("main:glass", {
    description = "Glass",
    tiles = {"glass.png"},
    drawtype = "glasslike",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
    groups = {glass = 1, pathable = 1},
    sounds = main.stoneSound({
		footstep = {name = "glass_footstep", gain = 0.4},
        dug =  {name = "break_glass", gain = 0.4},
	}),
    drop = "",
})
	
minetest.register_node("main:ice", {
    description = "Ice",
    tiles = {"ice.png"},
    drawtype = "glasslike",
	paramtype = "light",
	sunlight_propagates = true,
	sunlight_propagates = true,
	is_ground_content = false,
    groups = {glass = 1, pathable = 1,slippery=3},
    sounds = main.stoneSound({
		footstep = {name = "glass_footstep", gain = 0.4},
        dug =  {name = "break_glass", gain = 0.4},
	}),
	use_texture_alpha = false,
	alpha = 100,
    drop = "",
    after_destruct = function(pos, oldnode)
       minetest.set_node(pos, {name="main:water"})                            
    end                
})
minetest.register_node("main:ice_mapgen", {
    description = "Ice",
    tiles = {"ice.png"},
    drawtype = "normal",
	sunlight_propagates = true,
	sunlight_propagates = true,
	is_ground_content = false,
    groups = {glass = 1, pathable = 1,slippery=3},
    sounds = main.stoneSound({
		footstep = {name = "glass_footstep", gain = 0.4},
        dug =  {name = "break_glass", gain = 0.4},
	}),
	use_texture_alpha = false,
    drop = "",           
})

minetest.register_node("main:dirt", {
    description = "Dirt",
    tiles = {"dirt.png"},
    groups = {dirt = 1, soil=1,pathable = 1, farm_tillable=1},
    sounds = main.dirtSound(),
    paramtype = "light",
})

minetest.register_node("main:grass", {
    description = "Grass",
    tiles = {"grass.png"},
    groups = {grass = 1, soil=1,pathable = 1, farm_tillable=1},
    sounds = main.dirtSound(),
    drop="main:dirt",
})

minetest.register_node("main:sand", {
    description = "Sand",
    tiles = {"sand.png"},
    groups = {sand = 1, falling_node = 1,pathable = 1,soil=1},
    sounds = main.sandSound(),
})

minetest.register_node("main:gravel", {
    description = "Gravel",
    tiles = {"gravel.png"},
    groups = {sand = 1, falling_node = 1,pathable = 1},
    sounds = main.dirtSound(),
    drop = {
		max_items = 1,
		items= {
		 {
			-- Only drop if using a tool whose name is identical to one
			-- of these.
			rarity = 10,
			items = {"main:flint"},
			-- Whether all items in the dropped item list inherit the
			-- hardware coloring palette color from the dug node.
			-- Default is 'false'.
			--inherit_color = true,
		},
		{
			-- Only drop if using a tool whose name is identical to one
			-- of these.
			--tools = {"main:shears"},
			rarity = 0,
			items = {"main:gravel"},
			-- Whether all items in the dropped item list inherit the
			-- hardware coloring palette color from the dug node.
			-- Default is 'false'.
			--inherit_color = true,
		},
	}},
})

minetest.register_node("main:tree", {
    description = "Tree",
    tiles = {"treeCore.png","treeCore.png","treeOut.png","treeOut.png","treeOut.png","treeOut.png"},
    groups = {wood = 1, tree = 1, pathable = 1, flammable=1},
    sounds = main.woodSound(),
    --set metadata so treecapitator doesn't destroy houses
    on_place = function(itemstack, placer, pointed_thing)
		if not pointed_thing.type == "node" then
			return
		end
		
		local sneak = placer:get_player_control().sneak
		local noddef = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]
		if not sneak and noddef.on_rightclick then
			minetest.item_place(itemstack, placer, pointed_thing)
			return
		end
		
		local pos = pointed_thing.above
		minetest.item_place_node(itemstack, placer, pointed_thing)
		local meta = minetest.get_meta(pos)
		meta:set_string("placed", "true")	
		return(itemstack)
	end,
	--treecapitator - move treecapitator into own file using override
	on_dig = function(pos, node, digger)
		--bvav_create_vessel(pos,minetest.facedir_to_dir(minetest.dir_to_facedir(minetest.yaw_to_dir(digger:get_look_horizontal()+(math.pi/2)))))
		--check if wielding axe?
		--turn treecapitator into an enchantment?
		local meta = minetest.get_meta(pos)
		--local tool_meta = digger:get_wielded_item():get_meta()
		--if tool_meta:get_int("treecapitator") > 0 then
		if not meta:contains("placed") then
			--remove tree
			for y = -6,6 do
				local name = minetest.get_node(vector.new(pos.x,pos.y+y,pos.z)).name
				--print(y)
				if name == "main:tree" or name == "redstone:node_activated_tree" then
					minetest.node_dig(vector.new(pos.x,pos.y+y,pos.z), node, digger)
					local name2 = minetest.get_node(vector.new(pos.x,pos.y+y-1,pos.z)).name
					if name2 == "main:dirt" or name2 == "main:grass" then
						minetest.add_node(vector.new(pos.x,pos.y+y,pos.z),{name="main:sapling"})
					end
				end
			end
		else
			minetest.node_dig(pos, node, digger)
		end
		--else
		--	minetest.node_dig(pos, node, digger)
		--end
	end
})

minetest.register_node("main:wood", {
    description = "Wood",
    tiles = {"wood.png"},
    groups = {wood = 1, pathable = 1,flammable=1},
    sounds = main.woodSound(),
})

minetest.register_node("main:leaves", {
    description = "Leaves",
    drawtype = "allfaces_optional",
	waving = 1,
	walkable = false,
	climbable = true,
	paramtype = "light",
	is_ground_content = false,	
    tiles = {"leaves.png"},
    groups = {leaves = 1, leafdecay = 1,flammable=1},
    sounds = main.grassSound(),
    drop = {
		max_items = 1,
		items= {
		{
			tools = {"main:shears"},
			items = {"main:dropped_leaves"},
		},
		{
			rarity = 6,
			items = {"main:apple"},
		},
		{
			rarity = 10,
			items = {"main:sapling"},
		},
		},
    },
})


minetest.register_node("main:dropped_leaves", {
    description = "Leaves",
    drawtype = "allfaces_optional",
	waving = 0,
	walkable = false,
	climbable = false,
	paramtype = "light",
	is_ground_content = false,	
    tiles = {"leaves.png"},
    groups = {leaves = 1, flammable=1},
    sounds = main.grassSound(),
    drop = {
		max_items = 1,
		items= {
		{
			tools = {"main:shears"},
			items = {"main:dropped_leaves"},
		},
    },
    },
})






minetest.register_node("main:water", {
	description = "Water Source",
	drawtype = "liquid",
	waving = 3,
	tiles = {
		{
			name = "water_source.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1,
			},
		},
		{
			name = "water_source.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1,
			},
		},
	},
	alpha = 191,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "main:waterflow",
	liquid_alternative_source = "main:water",
	liquid_viscosity = 1,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 1, liquid = 1, cools_lava = 1, bucket = 1, source = 1,pathable = 1,drowning=1,disable_fall_damage=1},
	--sounds = default.node_sound_water_defaults(),
	
	--water explodes in the nether
	on_construct = function(pos)
		local under = minetest.get_node(vector.new(pos.x,pos.y-1,pos.z)).name
		if under == "nether:glowstone" then
			minetest.remove_node(pos)
			create_aether_portal(pos)
		elseif pos.y <= -10033 then
			minetest.remove_node(pos)
			tnt(pos,10)
		end
	end,
})

minetest.register_node("main:waterflow", {
	description = "Water Flow",
	drawtype = "flowingliquid",
	waving = 3,
	tiles = {"water_static.png"},
	special_tiles = {
		{
			name = "water_flow.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5,
			},
		},
		{
			name = "water_flow.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5,
			},
		},
	},
	selection_box = {
            type = "fixed",
            fixed = {
                {0, 0, 0, 0, 0, 0},
            },
        },
	alpha = 191,
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "main:waterflow",
	liquid_alternative_source = "main:water",
	liquid_viscosity = 1,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 1, liquid = 1, notInCreative = 1, cools_lava = 1,pathable = 1,drowning=1,disable_fall_damage=1},
	--sounds = default.node_sound_water_defaults(),
})

minetest.register_node("main:lava", {
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
	liquid_alternative_flowing = "main:lavaflow",
	liquid_alternative_source = "main:lava",
	liquid_viscosity = 7,
	liquid_renewable = false,
	post_effect_color = {a = 191, r = 255, g = 64, b = 0},
	groups = {lava = 3, liquid = 2, igniter = 1,hurt_inside=2},
})

minetest.register_node("main:lavaflow", {
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
	liquid_alternative_flowing = "main:lavaflow",
	liquid_alternative_source = "main:lava",
	liquid_viscosity = 7,
	liquid_renewable = false,
	liquid_range = 3,
	post_effect_color = {a = 191, r = 255, g = 64, b = 0},
	groups = {lava = 3, liquid = 2, igniter = 1,hurt_inside=2},
})

minetest.register_node("main:ladder", {
	description = "Ladder",
	drawtype = "signlike",
	tiles = {"ladder.png"},
	inventory_image = "ladder.png",
	wield_image = "ladder.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	climbable = true,
	is_ground_content = false,
	node_placement_prediction = "",
	selection_box = {
		type = "wallmounted",
		--wall_top = = <default>
		--wall_bottom = = <default>
		--wall_side = = <default>
	},
	groups = {wood = 1, flammable = 1, attached_node=1},
	sounds = main.woodSound(),
	on_place = function(itemstack, placer, pointed_thing)
		--copy from torch
		if pointed_thing.type ~= "node" then
			return itemstack
		end
		
		local wdir = minetest.dir_to_wallmounted(vector.subtract(pointed_thing.under,pointed_thing.above))

		local fakestack = itemstack
		local retval = false
		if wdir > 1 then
			retval = fakestack:set_name("main:ladder")
		else
			return itemstack
		end
		
		if not retval then
			return itemstack
		end
		
		itemstack, retval = minetest.item_place(fakestack, placer, pointed_thing, wdir)
		
		if retval then
			minetest.sound_play("wood", {pos=pointed_thing.above, gain = 1.0})
		end
		
		print(itemstack, retval)
		itemstack:set_name("main:ladder")

		return itemstack
	end,
})
