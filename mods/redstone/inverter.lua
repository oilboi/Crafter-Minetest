local
minetest,vector
=
minetest,vector

--[[
 ██████╗ ███╗   ██╗
██╔═══██╗████╗  ██║
██║   ██║██╔██╗ ██║
██║   ██║██║╚██╗██║
╚██████╔╝██║ ╚████║
 ╚═════╝ ╚═╝  ╚═══╝
]]--

--inverts redstone signal
minetest.register_node("redstone:inverter_on", {
    description = "Redstone Inverter",
    tiles = {"repeater_on.png"},
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,attached_node = 1,redstone_activation_directional=1},
    sounds = main.stoneSound(),
    paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	drawtype= "nodebox",
	drop="redstone:inverter_off",
	node_box = {
		type = "fixed",
		fixed = {
				--left  front  bottom right back top
				{-0.5, -0.5,  -0.5, 0.5,  -0.3, 0.5}, --base
				{-0.2, -0.5,  0.2, 0.2,  0.1, 0.4}, --output post
			},
		},
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local dir = minetest.facedir_to_dir(minetest.get_node(pos).param2)
		redstone.inject(pos,{
			name = "redstone:inverter_on",
			directional_activator = true,
			input  = vector.subtract(pos,dir),
			output = vector.add(pos,dir),
			dir = dir
		})
		redstone.update(pos)
		redstone.update(vector.add(pos,dir))
	end,
	after_destruct = function(pos, oldnode)
		local param2 = oldnode.param2
		local dir = minetest.facedir_to_dir(param2)
		redstone.inject(pos,nil)
		--redstone.update(pos)
		redstone.update(vector.add(pos,dir))
	end
})


redstone.register_activator({
	name = "redstone:inverter_on",
	deactivate = function(pos)
		local param2 = minetest.get_node(pos).param2
		minetest.swap_node(pos,{name="redstone:inverter_off",param2=param2})
		local dir = minetest.facedir_to_dir(param2)
		redstone.inject(pos,{
			name = "redstone:inverter_off",
			torch  = 16,
			torch_directional = true,
			directional_activator = true,
			input  = vector.subtract(pos,dir),
			output = vector.add(pos,dir),
			dir = dir
		})
		--redstone.update(pos)
		redstone.update(vector.add(pos,dir))
	end
})


minetest.register_lbm({
	name = "redstone:startupinverter",
	nodenames = {"redstone:inverter_on"},
	run_at_every_load = true,
	action = function(pos)
		local dir = minetest.facedir_to_dir(minetest.get_node(pos).param2)
		redstone.inject(pos,{
			name = "redstone:inverter_on",
			directional_activator = true,
			input  = vector.subtract(pos,dir),
			output = vector.add(pos,dir),
			dir = dir
		})
		--redstone.update(pos)
		redstone.update(vector.add(pos,dir))
	end,
})



--[[
 ██████╗ ███████╗███████╗
██╔═══██╗██╔════╝██╔════╝
██║   ██║█████╗  █████╗  
██║   ██║██╔══╝  ██╔══╝  
╚██████╔╝██║     ██║     
 ╚═════╝ ╚═╝     ╚═╝     
]]--

minetest.register_node("redstone:inverter_off", {
    description = "Redstone Inverter",
    tiles = {"repeater_off.png"},
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,attached_node = 1,redstone_activation_directional=1,torch_directional=1,redstone_power=16},
    sounds = main.stoneSound(),
    paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	drawtype= "nodebox",
	drop="redstone:inverter_off",
	node_box = {
		type = "fixed",
		fixed = {
				--left  front  bottom right back top
				{-0.5, -0.5,  -0.5, 0.5,  -0.3, 0.5}, --base
				{-0.2, -0.5,  0.2, 0.2,  0.1, 0.4}, --output post
			},
		},
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local dir = minetest.facedir_to_dir(minetest.get_node(pos).param2)
		redstone.inject(pos,{
			name = "redstone:inverter_off",
			torch  = 16,
			torch_directional = true,
			directional_activator = true,
			input  = vector.subtract(pos,dir),
			output = vector.add(pos,dir),
			dir = dir
		})
		redstone.update(pos)
		redstone.update(vector.add(pos,dir))
	end,
	after_destruct = function(pos, oldnode)
		local param2 = oldnode.param2
		local dir = minetest.facedir_to_dir(param2)
		redstone.inject(pos,nil)
		--redstone.update(pos)
		redstone.update(vector.add(pos,dir))
	end
})

redstone.register_activator({
	name = "redstone:inverter_off",
	activate = function(pos)
		
		local param2 = minetest.get_node(pos).param2
		minetest.swap_node(pos,{name="redstone:inverter_on",param2=param2})
		local dir = minetest.facedir_to_dir(param2)
		redstone.inject(pos,{
			name = "redstone:inverter_on",
			directional_activator = true,
			input  = vector.subtract(pos,dir),
			output = vector.add(pos,dir),
			dir = dir
		})
		--redstone.update(pos)
		redstone.update(vector.add(pos,dir))
	end
})


minetest.register_lbm({
	name = "redstone:also_startup_inverter",
	nodenames = {"redstone:inverter_off"},
	run_at_every_load = true,
	action = function(pos)
		local dir = minetest.facedir_to_dir(minetest.get_node(pos).param2)
		redstone.inject(pos,{
			name = "redstone:inverter_off",
			torch  = 16,
			torch_directional = true,
			directional_activator = true,
			input  = vector.subtract(pos,dir),
			output = vector.add(pos,dir),
			dir    = dir
		})
		--redstone.update(pos)
		redstone.update(vector.add(pos,dir))
	end,
})
