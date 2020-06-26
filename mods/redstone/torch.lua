local minetest,vector = minetest,vector


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
	groups = {choppy=2, dig_immediate=3, not_in_creative_inventory=1, attached_node=1, torch=1,redstone=1,redstone_torch=1,redstone_power=9},
	legacy_wallmounted = true,
	selection_box = {
		type = "fixed",
		fixed = {-1/16, -0.5, -1/16, 1/16, 2/16, 1/16},
	},
	
	on_construct = function(pos)
		redstone.collect_info(pos)
	end,
	after_destruct = function(pos, oldnode)
		redstone.collect_info(pos)
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
	groups = {choppy=2, dig_immediate=3, flammable=1, not_in_creative_inventory=1, attached_node=1, torch=1,redstone=1,redstone_torch=1,redstone_power=9},
	drop = "redstone:torch",
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.1, -0.1, -0.1, 0.1, 0.5, 0.1},
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, 0.1, 0.1},
		wall_side = {-0.5, -0.3, -0.1, -0.2, 0.3, 0.1},
	},
	on_construct = function(pos)		
		redstone.collect_info(pos)
	end,
	after_destruct = function(pos, oldnode)
		redstone.collect_info(pos)
	end,
	sounds = main.woodSound(),
})

