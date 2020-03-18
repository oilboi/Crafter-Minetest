--get point where particle spawner is added
local function get_offset(wdir)
	local z = 0
	local x = 0
	if wdir == 4 then
		z = 0.25
	elseif wdir == 2 then
		x = 0.25
	elseif wdir == 5 then
		z = -0.25
	elseif wdir == 3 then
		x = -0.25
	end
	return {x = x, y = 0.27, z = z}	
end

--remove smoke and fire
local function delete_ps(pos)
	local meta = minetest.get_meta(pos)
	minetest.delete_particlespawner(meta:get_int("psf"))
	minetest.delete_particlespawner(meta:get_int("pss"))
end

--add in smoke and fire
local function create_ps(pos)
	local dir = get_offset(minetest.get_node(pos).param2)
	local ppos = vector.add(dir,pos)
	local meta = minetest.get_meta(pos)
	local psf = minetest.add_particlespawner({
		amount = 2,
		time = 0,
		minpos = ppos,
		maxpos = ppos,
		minvel = vector.new(0,0,0),
		maxvel = vector.new(0,0,0),
		minacc = {x=0, y=0, z=0},
		maxacc = {x=0, y=0, z=0},
		minexptime = 1,
		maxexptime = 1,
		minsize = 3,
		maxsize = 3,
		collisiondetection = false,
		vertical = true,
		texture = "redstone_torch_animated.png",
		animation = {type = "vertical_frames",

			aspect_w = 16,
			-- Width of a frame in pixels

			aspect_h = 16,
			-- Height of a frame in pixels

			length =  0.2,
			-- Full loop length
		},
	})
	local pss = minetest.add_particlespawner({
		amount = 2,
		time = 0,
		minpos = ppos,
		maxpos = ppos,
		minvel = vector.new(-0.1,0.1,-0.1),
		maxvel = vector.new(0.1,0.3,0.1),
		minacc = vector.new(0,0,0),
		maxacc = vector.new(0,0,0),
		minexptime = 1,
		maxexptime = 2,
		minsize = 1,
		maxsize = 2,
		collisiondetection = false,
		vertical = false,
		texture = "smoke.png",
	})
	meta:set_int("psf", psf)
	meta:set_int("pss", pss)
end

--reload smoke and flame on load
--[[
minetest.register_lbm({
	name = "redstone:torch",
	nodenames = {"redstone:torch_floor","redstone:torch_wall"},
	run_at_every_load = true,
	action = function(pos, node)
		create_ps(pos)
	end,
})
]]--
-- Item definitions
minetest.register_craftitem("redstone:torch", {
	description = "Redstone Torch",
	inventory_image = "redstone_torch.png",
	wield_image = "redstone_torch.png",
	wield_scale = {x = 1, y = 1, z = 1 + 1/16},
	liquids_pointable = false,
	power = 9,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local wdir = minetest.dir_to_wallmounted(vector.subtract(pointed_thing.under,pointed_thing.above))

		local fakestack = itemstack
		local retval = false
		if wdir < 1 then
			return itemstack
		elseif wdir == 1 then
			retval = fakestack:set_name("redstone:torch_floor")
		else
			retval = fakestack:set_name("redstone:torch_wall")
		end
		if not retval then
			return itemstack
		end
		itemstack, retval = minetest.item_place(fakestack, placer, pointed_thing, wdir)
		itemstack:set_name("redstone:torch")

		if retval then
			minetest.sound_play("wood", {pos=pointed_thing.above, gain = 1.0})
		end

		return itemstack
	end
})

minetest.register_node("redstone:torch_floor", {
	inventory_image = "redstone_torch.png",
	wield_image = "redstone_torch.png",
	wield_scale = {x = 1, y = 1, z = 1 + 2/16},
	drawtype = "mesh",
	mesh = "torch_floor.obj",
	tiles = {"redstone_torch.png"},
	paramtype = "light",
	paramtype2 = "none",
	power = 9,
	sunlight_propagates = true,
	drop = "redstone:torch",
	walkable = false,
	light_source = 13,
	groups = {choppy=2, dig_immediate=3, not_in_creative_inventory=1, attached_node=1, torch=1,redstone=1,redstone_torch=1,connect_to_raillike=1},
	legacy_wallmounted = true,
	selection_box = {
		type = "fixed",
		fixed = {-1/16, -0.5, -1/16, 1/16, 2/16, 1/16},
	},
	
	on_construct = function(pos)
		--create_ps(pos)
		redstone.add(pos,true)
	end,
	after_destruct = function(pos, oldnode)
		redstone.remove(pos,9,true)
	end,
	sounds = main.woodSound(),
})

minetest.register_node("redstone:torch_wall", {
	inventory_image = "redstone_torch.png",
	wield_image = "redstone_torch.png",
	wield_scale = {x = 1, y = 1, z = 1 + 1/16},
	drawtype = "mesh",
	mesh = "torch_wall.obj",
	tiles = {"redstone_torch.png"},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	light_source = 13,
	power = 9,
	groups = {choppy=2, dig_immediate=3, flammable=1, not_in_creative_inventory=1, attached_node=1, torch=1,redstone=1,redstone_torch=1,connect_to_raillike=1},
	drop = "redstone:torch",
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.1, -0.1, -0.1, 0.1, 0.5, 0.1},
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, 0.1, 0.1},
		wall_side = {-0.5, -0.3, -0.1, -0.2, 0.3, 0.1},
	},
	on_construct = function(pos)
		--create_ps(pos)
		redstone.add(pos,true)
	end,
	after_destruct = function(pos, oldnode)
		redstone.remove(pos,9,true)
	end,
	sounds = main.woodSound(),
})


minetest.register_craftitem("redstone:blink_torch", {
	description = "Redstone Blink Torch",
	inventory_image = "redstone_torch.png",
	wield_image = "redstone_torch.png",
	wield_scale = {x = 1, y = 1, z = 1 + 1/16},
	liquids_pointable = false,
	power = 8,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local wdir = minetest.dir_to_wallmounted(vector.subtract(pointed_thing.under,pointed_thing.above))

		local fakestack = itemstack
		local retval = false
		if wdir < 1 then
			return itemstack
		elseif wdir == 1 then
			retval = fakestack:set_name("redstone:blink_torch_floor_1")
		else
			retval = fakestack:set_name("redstone:blink_torch_wall_1")
		end
		if not retval then
			return itemstack
		end
		itemstack, retval = minetest.item_place(fakestack, placer, pointed_thing, wdir)
		itemstack:set_name("redstone:blink_torch")

		if retval then
			minetest.sound_play("wood", {pos=pointed_thing.above, gain = 1.0})
		end

		return itemstack
	end
})
for i = 0,1 do
	local coloring = 160*(1-i)
	-- BLINK TORCH

	minetest.register_node("redstone:blink_torch_floor_"..i, {
		inventory_image = "redstone_torch.png",
		wield_image = "redstone_torch.png",
		wield_scale = {x = 1, y = 1, z = 1 + 2/16},
		drawtype = "mesh",
		mesh = "torch_floor.obj",
		tiles = {"redstone_torch.png^[colorize:black:"..coloring},
		paramtype = "light",
		paramtype2 = "none",
		power = 9*i,
		sunlight_propagates = true,
		drop = "redstone:torch",
		walkable = false,
		light_source = i*13,
		groups = {choppy=2, dig_immediate=3, not_in_creative_inventory=1, attached_node=1, torch=1,redstone=1,connect_to_raillike=1,blinker_torch = 1},
		legacy_wallmounted = true,
		selection_box = {
			type = "fixed",
			fixed = {-1/16, -0.5, -1/16, 1/16, 2/16, 1/16},
		},
		--there is no way for a player to get blink torch off
		--so shortcut is to add this to both states
		on_construct = function(pos)
			redstone.add(pos,true)
		end,
		after_destruct = function(pos, oldnode)
			redstone.remove(pos,9,true)
		end,
		sounds = main.woodSound(),
	})

	minetest.register_node("redstone:blink_torch_wall_"..i, {
		inventory_image = "redstone_torch.png",
		wield_image = "redstone_torch.png",
		wield_scale = {x = 1, y = 1, z = 1 + 1/16},
		drawtype = "mesh",
		mesh = "torch_wall.obj",
		tiles = {"redstone_torch.png^[colorize:black:"..coloring},
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		walkable = false,
		light_source = 13*i,
		power = 9*i,
		groups = {choppy=2, dig_immediate=3, flammable=1, not_in_creative_inventory=1, attached_node=1, torch=1,redstone=1,redstone_torch=1,connect_to_raillike=1,blinker_torch = 1},
		drop = "redstone:torch",
		selection_box = {
			type = "wallmounted",
			wall_top = {-0.1, -0.1, -0.1, 0.1, 0.5, 0.1},
			wall_bottom = {-0.1, -0.5, -0.1, 0.1, 0.1, 0.1},
			wall_side = {-0.5, -0.3, -0.1, -0.2, 0.3, 0.1},
		},
		on_construct = function(pos)
			redstone.add(pos,true)
		end,
		after_destruct = function(pos, oldnode)
			redstone.remove(pos,9,true)
		end,
		sounds = main.woodSound(),
	})

end


minetest.register_abm{
	label = "Torch Blink",
	nodenames = {"group:blinker_torch"},
	--neighbors = {"group:redstone"},
	interval = 0.7,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		--minetest.set_node(pos,{name=node.name:sub(1, -2)..0})
		--redstone.update(pos)
		local inversion = math.abs(tonumber(node.name:sub(#node.name, #node.name))-1) --never do this
		minetest.set_node(pos,{name=node.name:sub(1, #node.name-1)..inversion})
		if inversion == 1 then
			redstone.add(pos,true)
		elseif inversion == 0 then
			redstone.remove(pos,9,true)
		end
		
	end,
}
minetest.register_craft({
	output = "redstone:blink_torch 4",
	recipe = {
		{"redstone:dust"},
		{"redstone:dust"},
		{"main:stick"}
	},
})

minetest.register_craft({
	output = "redstone:torch 4",
	recipe = {
		{"redstone:dust"},
		{"main:stick"}
	}
})











--[[

minetest.register_craftitem("redstone:blink_torch", {
	description = "Redstone Blink Torch",
	inventory_image = "redstone_torch.png",
	wield_image = "redstone_torch.png",
	wield_scale = {x = 1, y = 1, z = 1 + 1/16},
	liquids_pointable = false,
	power = 8,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local wdir = minetest.dir_to_wallmounted(vector.subtract(pointed_thing.under,pointed_thing.above))

		local fakestack = itemstack
		local retval = false
		if wdir < 1 then
			return itemstack
		elseif wdir == 1 then
			retval = fakestack:set_name("redstone:blink_torch_floor_1")
		else
			retval = fakestack:set_name("redstone:blink_torch_wall_1")
		end
		if not retval then
			return itemstack
		end
		itemstack, retval = minetest.item_place(fakestack, placer, pointed_thing, wdir)
		itemstack:set_name("redstone:blink_torch")

		if retval then
			minetest.sound_play("wood", {pos=pointed_thing.above, gain = 1.0})
		end

		return itemstack
	end
})
for i = 0,1 do
	local coloring = 160*(1-i)
	-- BLINK TORCH

	minetest.register_node("redstone:blink_torch_floor_"..i, {
		inventory_image = "redstone_torch.png",
		wield_image = "redstone_torch.png",
		wield_scale = {x = 1, y = 1, z = 1 + 2/16},
		drawtype = "mesh",
		mesh = "torch_floor.obj",
		tiles = {"redstone_torch.png^[colorize:black:"..coloring},
		paramtype = "light",
		paramtype2 = "none",
		power = 8*i,
		sunlight_propagates = true,
		drop = "redstone:torch",
		walkable = false,
		light_source = i*13,
		groups = {choppy=2, dig_immediate=3, not_in_creative_inventory=1, attached_node=1, torch=1,redstone=1,connect_to_raillike=1,blinker_torch = 1},
		legacy_wallmounted = true,
		selection_box = {
			type = "fixed",
			fixed = {-1/16, -0.5, -1/16, 1/16, 2/16, 1/16},
		},
		on_construct = function(pos)
			redstone.update(pos)
		end,
		after_destruct = function(pos, oldnode)
			redstone.update(pos,oldnode)
		end,
		sounds = main.woodSound(),
	})

	minetest.register_node("redstone:blink_torch_wall_"..i, {
		inventory_image = "redstone_torch.png",
		wield_image = "redstone_torch.png",
		wield_scale = {x = 1, y = 1, z = 1 + 1/16},
		drawtype = "mesh",
		mesh = "torch_wall.obj",
		tiles = {"redstone_torch.png^[colorize:black:"..coloring},
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		walkable = false,
		light_source = 13*i,
		power = 8*i,
		groups = {choppy=2, dig_immediate=3, flammable=1, not_in_creative_inventory=1, attached_node=1, torch=1,redstone=1,redstone_torch=1,connect_to_raillike=1,blinker_torch = 1},
		drop = "redstone:torch",
		selection_box = {
			type = "wallmounted",
			wall_top = {-0.1, -0.1, -0.1, 0.1, 0.5, 0.1},
			wall_bottom = {-0.1, -0.5, -0.1, 0.1, 0.1, 0.1},
			wall_side = {-0.5, -0.3, -0.1, -0.2, 0.3, 0.1},
		},
		on_construct = function(pos)
			redstone.update(pos)
		end,
		after_destruct = function(pos, oldnode)
			redstone.update(pos,oldnode)
		end,
		sounds = main.woodSound(),
	})

end


minetest.register_abm{
	label = "Torch Blink",
	nodenames = {"group:blinker_torch"},
	--neighbors = {"group:redstone"},
	interval = 0.4,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		--minetest.set_node(pos,{name=node.name:sub(1, -2)..0})
		--redstone.update(pos)
		print("tests")
		local inversion = math.abs(tonumber(node.name:sub(#node.name, #node.name))-1) --never do this
		minetest.set_node(pos,{name=node.name:sub(1, #node.name-1)..inversion})
		redstone.update(pos)
	end,
}
minetest.register_craft({
	output = "redstone:blink_torch 4",
	recipe = {
		{"redstone:dust"},
		{"redstone:dust"},
		{"main:stick"}
	}
})
]]--

