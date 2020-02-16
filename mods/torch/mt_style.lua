minetest.register_craftitem(":default:torch", {
	description = "Torch",
	inventory_image = "default_torch_on_floor.png",
	wield_image = "default_torch_on_floor.png",
	wield_scale = {x = 1, y = 1, z = 1 + 1/16},
	liquids_pointable = false,
   	on_place = function(itemstack, placer, pointed_thing)
		local above = pointed_thing.above
		local under = pointed_thing.under
		local wdir = minetest.dir_to_wallmounted({x = under.x - above.x, y = under.y - above.y, z = under.z - above.z})
		if wdir < 1 and not torches.enable_ceiling then
			return itemstack
		end
		local fakestack = itemstack
		local retval = false
		if wdir <= 1 then
			retval = fakestack:set_name("torches:floor")
		else
			retval = fakestack:set_name("torches:wall")
		end
		if not retval then
			return itemstack
		end
		itemstack, retval = minetest.item_place(fakestack, placer, pointed_thing, wdir)
		itemstack:set_name("default:torch")

		return itemstack
	end
})

minetest.register_node("torches:floor", {
	description = "Torch",
	inventory_image = "default_torch.png",
	wield_image = "default_torch.png",
	wield_scale = {x = 1, y = 1, z = 1 + 1/16},
	drawtype = "mesh",
	mesh = "torch_floor.obj",
	tiles = {
		{
		    name = "default_torch_on_floor_animated.png",
		    animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
		}
	},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	light_source = 13,
	groups = {choppy=2, dig_immediate=3, flammable=1, not_in_creative_inventory=1, attached_node=1, torch=1},
	drop = "default:torch",
	selection_box = {
		type = "wallmounted",
		wall_top = {-1/16, -2/16, -1/16, 1/16, 0.5, 1/16},
		wall_bottom = {-1/16, -0.5, -1/16, 1/16, 2/16, 1/16},
	},
})

minetest.register_node("torches:wall", {
	inventory_image = "default_torch.png",
	wield_image = "default_torch.png",
	wield_scale = {x = 1, y = 1, z = 1 + 1/16},
	drawtype = "mesh",
	mesh = "torch_wall.obj",
	tiles = {
		{
		    name = "default_torch_on_floor_animated.png",
		    animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
		}
	},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	light_source = 13,
	groups = {choppy=2, dig_immediate=3, flammable=1, not_in_creative_inventory=1, attached_node=1, torch=1},
	drop = "default:torch",
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.1, -0.1, -0.1, 0.1, 0.5, 0.1},
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, 0.1, 0.1},
		wall_side = {-0.5, -0.3, -0.1, -0.2, 0.3, 0.1},
	},
})

-- convert old torches and remove ceiling placed
minetest.register_abm({
	nodenames = {"default:torch"},
	interval = 1,
	chance = 1,
	action = function(pos)
		local n = minetest.get_node(pos)
		local def = minetest.registered_nodes[n.name]
		if n and def then
			local wdir = n.param2
			local node_name = "torches:wall"
			if wdir < 1 and not torches.enable_ceiling then
				minetest.remove_node(pos)
				return
			elseif wdir <= 1 then
				node_name = "torches:floor"
			end
			minetest.set_node(pos, {name = node_name, param2 = wdir})
		end
	end
})
