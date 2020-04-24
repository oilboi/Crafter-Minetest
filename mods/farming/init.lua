--Quick definition of hoes
local material = {"wood","stone","iron","gold","diamond"}

local function till_soil(pos)
	local is_dirt = minetest.get_node_group(minetest.get_node(pos).name, "farm_tillable") > 0
	local is_farmland = minetest.get_node_group(minetest.get_node(pos).name, "farmland") > 0
	if is_dirt and not is_farmland then
		minetest.sound_play("dirt",{pos=pos})
		minetest.set_node(pos,{name="farming:farmland_dry"})
		return(true)
	end
end

for level,material in pairs(material) do
	local wear = 100*(6-level)
	local groupcaps2
	if material == "wood" then
		groupcaps2={
			dirt =  {times={[1]=0.4,[2]=1.5,[3]=3,[4]=6,[5]=12},    uses=59, maxlevel=1},
			snow =  {times={[1]=0.4,[2]=1.5,[3]=3,[4]=6,[5]=12},    uses=59, maxlevel=1},
			grass = {times={[1]=0.45,[2]=1.5,[3]=3,[4]=6,[5]=12},   uses=59, maxlevel=1},
			sand =  {times={[1]=0.4,[2]=1.5,[3]=3,[4]=6,[5]=12},    uses=59, maxlevel=1},
		}
		damage = 2.5
	elseif material == "stone" then
		groupcaps2={
			dirt =  {times={[1]=0.2,[2]=0.2,[3]=1.5,[4]=3,[5]=6},   uses=131, maxlevel=1},
			snow =  {times={[1]=0.2,[2]=0.2,[3]=1.5,[4]=3,[5]=6},   uses=131, maxlevel=1},
			grass = {times={[1]=0.25,[2]=0.25,[3]=1.5,[4]=3,[5]=6}, uses=131, maxlevel=1},
			sand =  {times={[1]=0.2,[2]=0.2,[3]=1.5,[4]=3,[5]=6},   uses=131, maxlevel=1},
		}
		damage = 3.5
	elseif material == "iron" then
		groupcaps2={
			dirt =  {times={[1]=0.15,[2]=0.15,[3]=0.15,[4]=1.5,[5]=3}, uses=250, maxlevel=1},
			snow =  {times={[1]=0.15,[2]=0.15,[3]=0.15,[4]=1.5,[5]=3}, uses=250, maxlevel=1},
			grass = {times={[1]=0.15,[2]=0.15,[3]=0.15,[4]=1.5,[5]=3}, uses=250, maxlevel=1},
			sand =  {times={[1]=0.15,[2]=0.15,[3]=0.15,[4]=1.5,[5]=3}, uses=250, maxlevel=1},
		}
		damage = 4.5
	elseif material == "gold" then
		groupcaps2={
			dirt =  {times={[1]=0.1,[2]=0.1,[3]=0.1,[4]=0.1,[5]=1.5}, uses=32, maxlevel=1},
			snow =  {times={[1]=0.1,[2]=0.1,[3]=0.1,[4]=0.1,[5]=1.5}, uses=32, maxlevel=1},
			grass = {times={[1]=0.1,[2]=0.1,[3]=0.1,[4]=0.1,[5]=1.5}, uses=32, maxlevel=1},
			sand =  {times={[1]=0.1,[2]=0.1,[3]=0.1,[4]=0.1,[5]=1.5}, uses=32, maxlevel=1},
		}
		damage = 2.5
	elseif material == "diamond" then
		groupcaps2={
			dirt =  {times={[1]= 0.1,[2]=0.1,[3]=0.1,[4]=0.1,[5]=1.5},     uses=1561, maxlevel=1},
			snow =  {times={[1]= 0.1,[2]=0.1,[3]=0.1,[4]=0.1,[5]=1.5},     uses=1561, maxlevel=1},
			grass = {times={[1]= 0.15,[2]=0.15,[3]=0.15,[4]=0.15,[5]=1.5}, uses=1561, maxlevel=1},
			sand =  {times={[1]= 0.1,[2]=0.1,[3]=0.1,[4]=0.1,[5]=1.5},     uses=1561, maxlevel=1},
		}
		damage = 5.5
	end
	minetest.register_tool("farming:"..material.."hoe", {
		description = material:gsub("^%l", string.upper).." Hoe",
		inventory_image = material.."hoe.png",
		tool_capabilities = {
				--full_punch_interval = 1.2,
				--max_drop_level=0,
				groupcaps=groupcaps2,
				damage_groups = {damage=damage},
			},
		sound = {breaks = {name="tool_break",gain=0.4}}, -- change this
		groups = {flammable = 2, tool=1 },
		
		on_place = function(itemstack, placer, pointed_thing)
			local noddef = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]
			local sneak = placer:get_player_control().sneak
			
			if not sneak and noddef.on_rightclick then
				minetest.item_place(itemstack, placer, pointed_thing)
				return
			end
		
			local tilled = till_soil(pointed_thing.under)
			if tilled == true then 
				if minetest.registered_nodes[minetest.get_node(vector.new(pointed_thing.under.x,pointed_thing.under.y+1,pointed_thing.under.z)).name].buildable_to then
					minetest.dig_node(vector.new(pointed_thing.under.x,pointed_thing.under.y+1,pointed_thing.under.z))
				end
				itemstack:add_wear(wear)
			end
			
			local damage = itemstack:get_wear()
			if damage <= 0 and tilled == true  then
				minetest.sound_play("tool_break",{object=placer})
			end
			return(itemstack)
		end,
	})
	minetest.register_craft({
		output = "farming:"..material.."hoe",
		recipe = {
			{"","main:"..material, "main:"..material},
			{"","main:stick", ""},
			{"", "main:stick", ""}
		}
	})
	minetest.register_craft({
		output = "farming:"..material.."hoe",
		recipe = {
			{"main:"..material,"main:"..material, ""},
			{"","main:stick", ""},
			{"", "main:stick", ""}
		}
	})
end

local farmland = {"wet","dry"}

for level,dryness in pairs(farmland) do
	local coloring = 160/level

	minetest.register_node("farming:farmland_"..dryness,{
		description = "Farmland",
		paramtype = "light",
		drawtype = "nodebox",
		sounds = main.dirtSound(),
		--paramtype2 = "wallmounted",
		node_box = {
			type = "fixed",
			--{xmin, ymin, zmin, xmax, ymax, zmax}

			fixed = {-0.5, -0.5, -0.5, 0.5, 6/16, 0.5},
		},
		wetness = math.abs(level-2),
		collision_box = {
			type = "fixed",
			--{xmin, ymin, zmin, xmax, ymax, zmax}

			fixed = {-0.5, -0.5, -0.5, 0.5, 6/16, 0.5},
		},
		tiles = {"dirt.png^farmland.png^[colorize:black:"..coloring,"dirt.png^[colorize:black:"..coloring,"dirt.png^[colorize:black:"..coloring,"dirt.png^[colorize:black:"..coloring,"dirt.png^[colorize:black:"..coloring,"dirt.png^[colorize:black:"..coloring},
		groups = {dirt = 1, soft = 1, shovel = 1, hand = 1, soil=1,farmland=1},
		drop="main:dirt",
	})
end


--drying and wetting abm for farmland
minetest.register_abm({
	label = "Farmland Wet",
	nodenames = {"farming:farmland_dry"},
	neighbors = {"air","group:crop"},
	interval = 3,
	chance = 150,
	action = function(pos)
		local found = minetest.find_node_near(pos, 3, {"main:water","main:waterflow"})
		if found then
			minetest.set_node(pos,{name="farming:farmland_wet"})
		else
			minetest.set_node(pos,{name="main:dirt"})
		end
	end,
})
minetest.register_abm({
	label = "Farmland dry",
	nodenames = {"farming:farmland_wet"},
	neighbors = {"air"},
	interval = 5,
	chance = 500,
	action = function(pos)
		local found = minetest.find_node_near(pos, 3, {"main:water","main:waterflow"})
		if not found then
			minetest.set_node(pos,{name="farming:farmland_dry"})
		end
	end,
})


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
			-- Only drop if using a tool whose name is identical to one
			-- of these.
			rarity = 10,
			items = {"farming:seeds"},
			-- Whether all items in the dropped item list inherit the
			-- hardware coloring palette color from the dug node.
			-- Default is 'false'.
			--inherit_color = true,
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
	health = 3,
})

minetest.register_craftitem("farming:toast", {
	description = "Toast",
	inventory_image = "bread.png^[colorize:black:100",
	health = 5,
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
