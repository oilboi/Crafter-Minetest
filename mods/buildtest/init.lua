minetest.register_node("buildtest:glass_pipe", {
	description = "Glass Pipe",
	tiles = {"glass_pipe.png"},
	groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4},
	sounds = main.stoneSound(),
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	connects_to = {"buildtest:glass_pipe","hopper:hopper"},
	node_box = {
		type = "connected",
		-- {x1, y1, z1, x2, y2, z2}
		disconnected  = {
			{-3/16,-3/16,-3/16,3/16,3/16,3/16}
			},
		connect_top = {
			{-3/16,-3/16,-3/16,3/16,8/16,3/16}
			},
		connect_bottom = {
			{-3/16,-8/16,-3/16,3/16,3/16,3/16}
			},
			
			
		connect_left = {
			{-8/16,-3/16,-3/16,3/16,3/16,3/16}
			},
		connect_right = {
			{-3/16,-3/16,-3/16,8/16,3/16,3/16}
			},
			
			
		connect_front = {
			{-3/16,-3/16,-8/16,3/16,3/16,3/16}
			},
		
		connect_back = {
			{-3/16,-3/16,-3/16,3/16,3/16,8/16}
			},
	},
})
