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
	--make the repeater turn on
	redstone_activation = function(pos)
		
	end,
	on_timer = function(pos, elapsed)
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
	end,
	redstone_deactivation = function(pos)
		local param2 = minetest.get_node(pos).param2
		minetest.swap_node(pos,{name="redstone:inverter_off",param2=param2})
		local dir = minetest.facedir_to_dir(param2)
		redstone.collect_info(vector.add(pos,dir))
	end,
	redstone_update = function(pos)
	end,
	on_construct = function(pos)
	end,
	after_destruct  = function(pos)
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
	end,
})

minetest.register_node("redstone:inverter_off", {
    description = "Redstone Inverter",
    tiles = {"repeater_off.png"},
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,attached_node = 1,redstone_activation_directional=1,torch_directional=1,redstone_power=9},
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
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
	end,
	redstone_activation = function(pos)
		local param2 = minetest.get_node(pos).param2
		minetest.swap_node(pos,{name="redstone:inverter_on",param2=param2})
		local dir = minetest.facedir_to_dir(param2)
		redstone.collect_info(vector.add(pos,dir))
	end,
	redstone_deactivation = function(pos)
	end,
	on_timer = function(pos, elapsed)
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		redstone.collect_info(pos)
	end,
	on_dig = function(pos, node, digger)
		minetest.node_dig(pos, node, digger)
		redstone.collect_info(pos)
	end,
	redstone_update = function(pos)
	end,
	on_construct = function(pos)
	end,
	after_destruct = function(pos)
	end,
})
