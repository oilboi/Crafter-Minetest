minetest.register_node("minecart:rail",{
	description = "Rail",
	wield_image = "rail.png",
	tiles = {
		"rail.png", "railcurve.png",
		"railt.png", "railcross.png"
	},
	drawtype = "raillike",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	node_placement_prediction = "",
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
	on_place = function(itemstack, placer, pointed_thing)
		if not pointed_thing.type == "node" then
			return
		end
		local pos = pointed_thing.above
		if minetest.registered_nodes[minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name].walkable then
			minetest.set_node(pointed_thing.above, {name="minecart:rail"})
			itemstack:take_item(1)
			return(itemstack)
		end
	end,
	groups={instant=1,rail=1},
})

minetest.register_craft({
	output = "minecart:rail 32",
	recipe = {
		{"main:iron","","main:iron"},
		{"main:iron","main:stick","main:iron"},
		{"main:iron","","main:iron"}
	}
})
