--saplings
--
--
--local sapling_min = 120
--local sapling_max = 720
--make sapling grow
local function sapling_grow(pos)
	if minetest.get_node_light(pos, nil) < 10 then
		--print("failed to grow at "..dump(pos))
		return
	end
	--print("growing at "..dump(pos))
	if minetest.get_item_group(minetest.get_node(vector.new(pos.x,pos.y-1,pos.z)).name, "soil") > 0 then
		local good_to_grow = true
		--check if room to grow (leaves or air)
		for i = 1,4 do
			local node_name = minetest.get_node(vector.new(pos.x,pos.y+i,pos.z)).name
			if node_name ~= "air" and node_name ~= "main:leaves" then
				good_to_grow = false
			end
		end
		if good_to_grow == true then
			minetest.set_node(pos,{name="main:tree"})
			local schemmy = math.random(1,2)
			if schemmy == 1 then
				minetest.place_schematic(pos, tree_big,"0",nil,false,"place_center_x, place_center_z")
			elseif schemmy == 2 then
				minetest.place_schematic(pos, tree_small,"0",nil,false,"place_center_x, place_center_z")
			end
			--override leaves
			local max = 3
			if schemmy == 2 then
				max = 1
			end
			for i = 1,max do
				minetest.set_node(vector.new(pos.x,pos.y+i,pos.z),{name="main:tree"})
			end
		end
	end
end

minetest.register_node("main:sapling", {
	description = "Sapling",
	drawtype = "plantlike",
	inventory_image = "sapling.png",
	waving = 1,
	walkable = false,
	climbable = false,
	paramtype = "light",
	is_ground_content = false,	
	tiles = {"sapling.png"},
	groups = {leaves = 1, plant = 1, axe = 1, hand = 0,instant=1, sapling=1, attached_node=1,flammable=1},
	sounds = main.dirtSound(),
	drop = "main:sapling",
	node_placement_prediction = "",
	selection_box = {
		type = "fixed",
		fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, 7 / 16, 4 / 16}
	},
	on_place =  function(itemstack, placer, pointed_thing)
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
		if buildable and minetest.get_item_group(minetest.get_node(vector.new(pointed_thing.under.x,pointed_thing.under.y-1,pointed_thing.under.z)).name, "soil") > 0 then
			return(minetest.item_place(itemstack, placer, pointed_thing))
		end
		local buildable = minetest.registered_nodes[minetest.get_node(pointed_thing.above).name].buildable_to
		if buildable and minetest.get_item_group(minetest.get_node(vector.new(pointed_thing.above.x,pointed_thing.above.y-1,pointed_thing.above.z)).name, "soil") > 0 then
			return(minetest.item_place(itemstack, placer, pointed_thing))
		end
		--place sapling
		local pos = pointed_thing.above
		if minetest.get_item_group(minetest.get_node(vector.new(pos.x,pos.y-1,pos.z)).name, "soil") > 0 and minetest.get_node(pointed_thing.above).name == "air" then
			minetest.set_node(pointed_thing.above, {name="main:sapling"})
			minetest.sound_play("dirt",{pos=pointed_thing.above})
			itemstack:take_item(1)
			return(itemstack)
		end
	end,
})


--growing abm for sapling
minetest.register_abm({
	label = "Tree Grow",
	nodenames = {"group:sapling"},
	neighbors = {"group:soil"},
	interval = 6,
	chance = 250,
	catch_up = true,
	action = function(pos)
		sapling_grow(pos)
	end,
})
