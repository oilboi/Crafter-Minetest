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
	sounds = main.stoneSound(),
	on_place = function(itemstack, placer, pointed_thing)
		if not pointed_thing.type == "node" then
			return
		end
		
		local sneak = placer:get_player_control().sneak
		local noddef = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]
		if not sneak and noddef.on_rightclick then
			minetest.item_place(itemstack, placer, pointed_thing)
			return
		end
		local buildable = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name].buildable_to
		--replace buildable
		if buildable and minetest.get_node_group(minetest.get_node(vector.new(pointed_thing.under.x,pointed_thing.under.y-1,pointed_thing.under.z)).name, "soil") > 0 then
			return(minetest.item_place(itemstack, placer, pointed_thing))
		end
		--replace buildable above
		local buildable = minetest.registered_nodes[minetest.get_node(pointed_thing.above).name].buildable_to
		if buildable and minetest.get_node_group(minetest.get_node(vector.new(pointed_thing.above.x,pointed_thing.above.y-1,pointed_thing.above.z)).name, "soil") > 0 then
			return(minetest.item_place(itemstack, placer, pointed_thing))
		end
		--normal
		local pos = pointed_thing.above
		if minetest.registered_nodes[minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name].walkable and minetest.get_node(pointed_thing.above).name == "air" then
			minetest.set_node(pointed_thing.above, {name="minecart:rail"})
			itemstack:take_item(1)
			minetest.sound_play("stone",{pos=pointed_thing.above})
			return(itemstack)
		end
	end,
	groups={stone=1,wood=1,rail=1},
})

minetest.register_craft({
	output = "minecart:rail 32",
	recipe = {
		{"main:iron","","main:iron"},
		{"main:iron","main:stick","main:iron"},
		{"main:iron","","main:iron"}
	}
})
