
local
minetest,vector,math,pairs
=
minetest,vector,math,pairs


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
		minetest.swap_node(pos, {name="redstone:lever_off",param2=node.param2})

		minetest.sound_play("lever", {pos=pos})

		local dir = minetest.wallmounted_to_dir(node.param2)

		redstone.inject(pos,nil)
		local pos2 = vector.add(dir,pos)
		redstone.inject(pos2,nil)

		redstone.update(pos)
		redstone.update(pos2)
	end,
	after_destruct = function(pos, oldnode)
		redstone.inject(pos,nil)
		local dir = minetest.wallmounted_to_dir(oldnode.param2)
		local pos2 = vector.add(dir,pos)
		redstone.inject(pos2,nil)

		redstone.update(pos)
		redstone.update(pos2)
	end,
})

minetest.register_lbm({
	name = "redstone:lever_on",
	nodenames = {"redstone:lever_on"},
	run_at_every_load = true,
	action = function(pos)
		local dir = minetest.wallmounted_to_dir(node.param2)
		redstone.inject(pos,{torch=9})
		local pos2 = vector.add(dir,pos)
		redstone.inject(pos2,{torch=9})
		minetest.after(0,function()
			redstone.update(pos)
			redstone.update(pos2)
		end)
	end,
})



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
		minetest.swap_node(pos, {name="redstone:lever_on",param2=node.param2})
		minetest.sound_play("lever", {pos=pos})

		local dir = minetest.wallmounted_to_dir(node.param2)

		redstone.inject(pos,{torch=9})
		local pos2 = vector.add(dir,pos)
		redstone.inject(pos2,{torch=9})

		redstone.update(pos)
		redstone.update(pos2)
	end,
	after_destruct = function(pos, oldnode)
		redstone.inject(pos,nil)
		local dir = minetest.wallmounted_to_dir(oldnode.param2)
		local pos2 = vector.add(dir,pos)
		redstone.inject(pos2,nil)

		redstone.update(pos)
		redstone.update(pos2)
	end,
})