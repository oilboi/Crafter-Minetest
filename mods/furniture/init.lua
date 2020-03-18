
minetest.register_node("furniture:window", {
description = "Window",
drawtype = "nodebox",
paramtype = "light",
paramtype2 = "facedir",
tiles = {"glass.png"},
buildable_to = true,
wield_image = "glass.png",
inventory_image  = "glass.png",
groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,pathable = 1},
on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
	local param2 = node.param2
	minetest.set_node(pos,{name="furniture:window_"..math.abs(i-1),param2=param2})
end,
sounds = main.stoneSound({
	footstep = {name = "glass_footstep", gain = 0.4},
	dug =  {name = "break_glass", gain = 0.4},
}),
drop = "",
selection_box = {
	type = "fixed",
	fixed = {-0.5, -0.5, -0.05, 0.5, 0.5, 0.05},
},
node_box = {
	type = "fixed",
	fixed = {-0.5, -0.5, -0.05, 0.5, 0.5, 0.05},
	},
})


minetest.register_craft({
	output = "furniture:window 6",
	recipe = {
		{"main:glass", "main:glass"},
		{"main:glass", "main:glass"},
	}
})
