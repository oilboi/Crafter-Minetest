local particle_time = 5 -- how many seconds torches will wait to check if player is near
local check_radius = 10

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
--add in smoke and fire
local function create_ps(pos)
	local dir = get_offset(minetest.get_node(pos).param2)
	local ppos = vector.add(dir,pos)
	minetest.add_particle({
		pos = ppos,
		velocity = vector.new(0,0,0),
		acceleration = vector.new(0,0,0),
		expirationtime = particle_time*3,
		size = 3,
		collisiondetection = false,
		vertical = true,
		texture = "torch_animated.png",
		animation = {type = "vertical_frames",

			aspect_w = 16,
			-- Width of a frame in pixels

			aspect_h = 16,
			-- Height of a frame in pixels

			length =  0.2,
			-- Full loop length
		},
	})
	--[[
	minetest.add_particlespawner({
		amount = particle_time*6,
		time = particle_time*2,
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
	]]--
end


--reload smoke and flame on load
--[[
minetest.register_abm({
	label = "Torch Particle",
	nodenames = {"group:torch"},
	neighbors = {"air"},
	interval = particle_time,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local found_player = false
		for _,object in ipairs(minetest.get_objects_inside_radius(pos, check_radius)) do
			local pos2 = object:getpos()
			if object:is_player() then
				found_player = true
			end
		end
		if found_player == true then
			create_ps(pos)
		end
	end,
})
]]--

-- Item definitions
minetest.register_craftitem("torch:torch", {
	description = "Torch",
	inventory_image = "torches_torch.png",
	wield_image = "torches_torch.png",
	wield_scale = {x = 1, y = 1, z = 1 + 1/16},
	liquids_pointable = false,
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
			retval = fakestack:set_name("torch:floor")
		else
			retval = fakestack:set_name("torch:wall")
		end
		if not retval then
			return itemstack
		end
		itemstack, retval = minetest.item_place(fakestack, placer, pointed_thing, wdir)
		itemstack:set_name("torch:torch")

		if retval then
			minetest.sound_play("wood", {pos=pointed_thing.above, gain = 1.0})
		end

		return itemstack
	end
})

minetest.register_node("torch:floor", {
	inventory_image = "default_torch.png",
	wield_image = "torches_torch.png",
	wield_scale = {x = 1, y = 1, z = 1 + 2/16},
	drawtype = "mesh",
	mesh = "torch_floor.obj",
	tiles = {"torches_torch.png"},
	paramtype = "light",
	paramtype2 = "none",
	sunlight_propagates = true,
	drop = "torch:torch",
	walkable = false,
	light_source = 13,
	groups = {choppy=2, dig_immediate=3, flammable=1, not_in_creative_inventory=1, attached_node=1, torch=1},
	legacy_wallmounted = true,
	selection_box = {
		type = "fixed",
		fixed = {-1/16, -0.5, -1/16, 1/16, 2/16, 1/16},
	},
	sounds = main.woodSound(),
})

minetest.register_node("torch:wall", {
	inventory_image = "default_torch.png",
	wield_image = "torches_torch.png",
	wield_scale = {x = 1, y = 1, z = 1 + 1/16},
	drawtype = "mesh",
	mesh = "torch_wall.obj",
	tiles = {"torches_torch.png"},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	light_source = 13,
	groups = {choppy=2, dig_immediate=3, flammable=1, not_in_creative_inventory=1, attached_node=1, torch=1},
	drop = "torch:torch",
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.1, -0.1, -0.1, 0.1, 0.5, 0.1},
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, 0.1, 0.1},
		wall_side = {-0.5, -0.3, -0.1, -0.2, 0.3, 0.1},
	},
	sounds = main.woodSound(),
})

minetest.register_craft({
	output = "torch:torch 4",
	recipe = {
		{"main:coal"},
		{"main:stick"}
	}
})
minetest.register_craft({
	output = "torch:torch 4",
	recipe = {
		{"main:charcoal"},
		{"main:stick"}
	}
})
