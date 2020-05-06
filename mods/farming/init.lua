local path = minetest.get_modpath("farming")
dofile(path.."/tools.lua")
dofile(path.."/soil.lua")



minetest.register_node("farming:grass", {
    description = "Tall Grass",
    drawtype = "plantlike",
	waving = 1,
	inventory_image = "tallgrass.png",
	walkable = false,
	climbable = false,
	paramtype = "light",
	is_ground_content = false,	
    tiles = {"tallgrass.png"},
    paramtype2 = "degrotate",
    buildable_to = true,
    groups = {dig_immediate=1,attached_node=1,flammable=1},
    sounds = main.grassSound(),
    floodable = true,
    selection_box = {
		type = "fixed",
		fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, 4 / 16, 4 / 16}
	},
	drop =  {
		max_items = 1,
		items= {
		 {
			rarity = 10,
			items = {"farming:seeds"},
		},
		},
	},
})

--register sugarcane in here since it's part of farming
minetest.register_abm({
	label = "Sugarcane Grow",
	nodenames = {"main:sugarcane"},
	neighbors = {"air"},
	interval = 3,
	chance = 150,
	action = function(pos)
		local found = minetest.find_node_near(pos, 4, {"main:water","main:waterflow"})
		if found then
			pos.y = pos.y + 1
			if minetest.get_node(pos).name == "air" then
				minetest.set_node(pos,{name="main:sugarcane"})
			end
		end
	end,
})

--register cactus in here since it's part of farming
minetest.register_abm({
	label = "Cactus Grow",
	nodenames = {"main:cactus"},
	neighbors = {"air"},
	interval = 3,
	chance = 150,
	action = function(pos)
		pos.y = pos.y + 1
		if minetest.get_node(pos).name == "air" then
			minetest.set_node(pos,{name="main:cactus"})
		end
	end,
})

--wheat definitions
local wheat_max = 7
minetest.register_abm({
	label = "crops grow",
	nodenames = {"group:crops"},
	neighbors = {"group:farmland"},
	interval = 3,
	chance = 150,
	action = function(pos)
		
		local node_under = minetest.get_node(vector.new(pos.x,pos.y-1,pos.z)).name
		local wetness = minetest.registered_nodes[node_under].wetness
		
		if wetness == 0 or not wetness then
			return
		end
		
		local node = minetest.get_node(pos).name
		local stage = minetest.registered_nodes[node].grow_stage
		if stage < wheat_max then
			minetest.set_node(pos,{name="farming:wheat_"..stage+1})
		end
	end,
})

for i = 0,wheat_max do
	local drop = ""
	if i == wheat_max then 
		drop = {
			max_items = 2,
			items= {
			 {
				-- Only drop if using a tool whose name is identical to one
				-- of these.
				--rarity = 10,
				items = {"farming:wheat"},
				-- Whether all items in the dropped item list inherit the
				-- hardware coloring palette color from the dug node.
				-- Default is 'false'.
				--inherit_color = true,
			},
			{
				-- Only drop if using a tool whose name is identical to one
				-- of these.
				rarity = 3,
				items = {"farming:seeds"},
				-- Whether all items in the dropped item list inherit the
				-- hardware coloring palette color from the dug node.
				-- Default is 'false'.
				--inherit_color = true,
			},
			},
			}
		
	     
	end
	
	minetest.register_node("farming:wheat_"..i, {
	    description = "Wheat Stage "..i,
	    drawtype = "plantlike",
		waving = 1,
		walkable = false,
		climbable = false,
		paramtype = "light",
		is_ground_content = false,	
	    tiles = {"wheat_stage_"..i..".png"},
	    paramtype2 = "degrotate",
	    buildable_to = true,
	    grow_stage = i,
	    groups = {leaves = 1, plant = 1, axe = 1, hand = 0,dig_immediate=1,attached_node=1,crops=1},
	    sounds = main.grassSound(),
	    selection_box = {
			type = "fixed",
			fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, 4 / 16, 4 / 16}
		},
		drop = drop,
	})
end


minetest.register_craftitem("farming:seeds", {
	description = "Seeds",
	inventory_image = "seeds.png",
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end
		local pb = pointed_thing.above
		if minetest.get_node_group(minetest.get_node(vector.new(pb.x,pb.y-1,pb.z)).name, "farmland") == 0 or minetest.get_node(pointed_thing.above).name ~= "air"  then
			return itemstack
		end

		local wdir = minetest.dir_to_wallmounted(vector.subtract(pointed_thing.under,pointed_thing.above))

		local fakestack = itemstack
		local retval = false

		retval = fakestack:set_name("farming:wheat_0")

		if not retval then
			return itemstack
		end
		itemstack, retval = minetest.item_place(fakestack, placer, pointed_thing, wdir)
		itemstack:set_name("farming:seeds")

		if retval then
			minetest.sound_play("leaves", {pos=pointed_thing.above, gain = 1.0})
		end

		return itemstack
	end
})


minetest.register_decoration({
	deco_type = "simple",
	place_on = "main:grass",
	sidelen = 16,
	fill_ratio = 0.5,
	--biomes = {"grassland"},
	decoration = "farming:grass",
	height = 1,
})


minetest.register_craftitem("farming:wheat", {
	description = "Wheat",
	inventory_image = "wheat_harvested.png",
})


minetest.register_craftitem("farming:bread", {
	description = "Bread",
	inventory_image = "bread.png",
	groups = {satiation=3,hunger=3},
})

minetest.register_craftitem("farming:toast", {
	description = "Toast",
	inventory_image = "bread.png^[colorize:black:100",
	groups = {satiation=4,hunger=4},
})

minetest.register_craft({
	output = "farming:bread",
	recipe = {
		{"farming:wheat", "farming:wheat", "farming:wheat"}
	}
})


minetest.register_craft({
	type = "cooking",
	output = "farming:toast",
	recipe = "farming:bread",
	cooktime = 3,
})
