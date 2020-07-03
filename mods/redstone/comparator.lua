local minetest,vector,math = minetest,vector,math


for i = 0,16 do
	minetest.register_node("redstone:comparator_"..i, {
		description = "Redstone Comparator",
		tiles = {"repeater_on.png"},
		groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,attached_node = 1,redstone_activation_directional=1,torch_directional=1,redstone_power=i,comparator=i},
		sounds = main.stoneSound(),
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		walkable = false,
		drawtype= "nodebox",
		drop="redstone:comparator_0",
		node_box = {
			type = "fixed",
			fixed = {
					--left  front  bottom right back top
					{-0.5, -0.5,  -0.5, 0.5,  -0.3, 0.5}, --base
					{-0.1, -0.5,  0.2, 0.1,  0.1, 0.4}, --output post
					{-0.4, -0.5,  -0.35, -0.2,  0.1, -0.15}, --input post
					{0.4, -0.5,  -0.35, 0.2,  0.1, -0.15}, --input post
				},
			},

		after_place_node = function(pos, placer, itemstack, pointed_thing)
			redstone.collect_info(pos)
		end,
		on_destruct = function(pos)
		end,
	})

end


