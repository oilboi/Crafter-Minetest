
local minetest,vector,math,pairs = minetest,vector,math,pairs


minetest.register_node("redstone:lever_off", {
    description = "Lever",
    tiles = {"stone.png"},
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,attached_node = 1,dig_immediate=1},
    sounds = main.stoneSound(),
    paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	drawtype= "nodebox",
	drop="redstone:lever_off",
	node_box = {
		type = "fixed",
		fixed = {
				--left front bottom right back top
				{-0.3, -0.5,  -0.4, 0.3,  -0.4, 0.4},
				{-0.1, -0.5,  -0.3, 0.1,  0, -0.1},
			},
		},
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		minetest.set_node(pos, {name="redstone:lever_on",param2=node.param2})
		minetest.sound_play("lever", {pos=pos})

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
minetest.register_node("redstone:lever_on", {
    description = "Lever On",
    tiles = {"stone.png"},
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,attached_node = 1,dig_immediate=1},
    sounds = main.stoneSound(),
    paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	drawtype= "nodebox",
	drop="redstone:lever_off",
	node_box = {
		type = "fixed",
		fixed = {
				--left front bottom right back top
				{-0.3, -0.5,  -0.4, 0.3,  -0.4, 0.4},
				{-0.1, -0.5,  0.3, 0.1,  0, 0.1},
			},
		},
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		minetest.set_node(pos, {name="redstone:lever_off",param2=node.param2})

		minetest.sound_play("lever", {pos=pos})

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
