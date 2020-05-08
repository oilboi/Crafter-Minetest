local path = minetest.get_modpath("farming")
dofile(path.."/plant_api.lua")
dofile(path.."/registers.lua")
dofile(path.."/tools.lua")
dofile(path.."/soil.lua")




--register sugarcane in here since it's part of farming
--[[
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
]]--

--wheat definitions
--[[
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
]]--




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
