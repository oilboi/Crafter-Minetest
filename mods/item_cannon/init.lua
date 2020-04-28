minetest.register_node("item_cannon:item_cannon", {
    description = "Item Cannon",
    paramtype = "light",
    paramtype2 = "facedir",
    tiles = {"bed_top.png^[transform1","wood.png","bed_side.png","bed_side.png^[transform4","bed_front.png","nothing.png"},
    groups = {wood = 1, hard = 1, axe = 1, hand = 3, instant=1,bouncy=50,attached_node=1},
    sounds = main.woodSound({placing=""}),
    drawtype = "nodebox",
    node_box = {
		type = "fixed",
		fixed = {
				{-0.5, -5/16, -0.5, 0.5, 0.06, 0.5},
				{-0.5, -0.5, 0.5, -5/16, -5/16, 5/16},
				{0.5, -0.5, 0.5, 5/16, -5/16, 5/16},
			},
		},
	node_placement_prediction = "",
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local param2 = minetest.get_node(pos).param2
		local dir = minetest.facedir_to_dir(param2)
		dir.y = 0.5
		
		local obj = minetest.add_item(pos,itemstack:get_name())
		if obj then
			local vel = vector.multiply(dir,30)
			obj:set_velocity(vel)
			itemstack:take_item(1)
			minetest.sound_play("tnt_explode", {pos = pos, gain = 1.0})
			return(itemstack)
		end
	end,
}) 
