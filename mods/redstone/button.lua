local minetest,table,vector = minetest,table,vector

minetest.register_node("redstone:button_off", {
    description = "Button",
    tiles = {"stone.png"},
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,attached_node = 1,dig_immediate=1},
    sounds = main.stoneSound(),
    paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	drawtype= "nodebox",
	drop="redstone:button_off",
	node_box = {
		type = "fixed",
		fixed = {
				--left front bottom right back top
				{-0.25, -0.5,  -0.15, 0.25,  -0.3, 0.15},
			},
		},
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		minetest.swap_node(pos, {name="redstone:button_on",param2=node.param2})

		minetest.sound_play("lever", {pos=pos})
		local timer = minetest.get_node_timer(pos)
		timer:start(1.25)

		local dir = minetest.wallmounted_to_dir(node.param2)
		pos = vector.add(dir,pos)
	
		local meta = minetest.get_meta(pos)

		meta:set_int("redstone_power", 9)

		redstone.collect_info(pos)
	end,
	after_destruct = function(pos, oldnode)
		local dir = minetest.wallmounted_to_dir(oldnode.param2)
		pos = vector.add(dir,pos)
	
		local meta = minetest.get_meta(pos)

		meta:set_int("redstone_power", 0)
		
		redstone.collect_info(pos)
	end,
})
minetest.register_node("redstone:button_on", {
    description = "Button",
    tiles = {"stone.png"},
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,attached_node = 1,dig_immediate=1},
    sounds = main.stoneSound(),
    paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	drawtype= "nodebox",
	drop="redstone:button_off",
	node_box = {
		type = "fixed",
		fixed = {
				--left front bottom right back top
				{-0.25, -0.5,  -0.15, 0.25,  -0.45, 0.15},
			},
		},
    on_timer = function(pos, elapsed)
		minetest.sound_play("lever", {pos=pos,pitch=0.8})

		local node = minetest.get_node(pos)
		minetest.swap_node(pos, {name="redstone:button_off",param2=node.param2})

		local dir = minetest.wallmounted_to_dir(node.param2)
		pos = vector.add(dir,pos)
	
		local meta = minetest.get_meta(pos)

		meta:set_int("redstone_power", 0)
		
		redstone.collect_info(pos)
		
	end,
	after_destruct = function(pos, oldnode)
		local dir = minetest.wallmounted_to_dir(oldnode.param2)
		pos = vector.add(dir,pos)
	
		local meta = minetest.get_meta(pos)

		meta:set_int("redstone_power", 0)
		
		redstone.collect_info(pos)
	end,
})
