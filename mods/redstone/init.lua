--define the class
redstone = {}
local r_index = {}

local path = minetest.get_modpath("redstone")
dofile(path.."/functions.lua")
dofile(path.."/wire.lua")
dofile(path.."/torch.lua")
dofile(path.."/lever.lua")
dofile(path.."/button.lua")
dofile(path.."/repeater.lua")
dofile(path.."/light.lua")
dofile(path.."/piston.lua")
dofile(path.."/comparator.lua")
dofile(path.."/craft.lua")
dofile(path.."/ore.lua")
dofile(path.."/inverter.lua")
dofile(path.."/player_detector.lua")
dofile(path.."/space_maker.lua")
dofile(path.."/pressure_plate.lua")


get_old_power = function(pos)
	local meta = minetest.get_meta(pos)
	local oldpower = meta:get_int("old_power")
	return(oldpower)	
end
--set the data for powered states
get_local_power = function(pos)
	local max_level = 0
	for x = -1,1 do
	for y = -1,1 do
	for z = -1,1 do
		--index only direct neighbors
		if not (math.abs(x)+math.abs(z) > 1) or (math.abs(x)+math.abs(z) == 0) then
			--print(minetest.get_node(vector.add(vector.new(x,y,z),pos)).name)
			local level = minetest.get_node_group(minetest.get_node(vector.add(vector.new(x,y,z),pos)).name, "redstone_power")
			if level > max_level then
				max_level = level
			end
		end
	end
	end
	end	
	return(max_level)
end

--this is used for a power state comparison
set_old_power = function(pos,level)
	local meta = minetest.get_meta(pos)
	meta:set_int("old_power",level)
end

get_powered_state_directional = function(pos)
	local meta = minetest.get_meta(pos)
	local node = minetest.get_node(pos)
	local param2 = node.param2
	local dir = minetest.facedir_to_dir(param2)
	local input_pos = vector.subtract(pos,dir)
	local behind_node = minetest.get_node(input_pos)
	local level = minetest.get_node_group(behind_node.name, "redstone_power")
	return(level)
end


local redstone_activate = function(name,pos,power)
	minetest.after(0,function(name,pos)
	if minetest.registered_nodes[name].redstone_activation then
		minetest.registered_nodes[name].redstone_activation(pos)
	end
	set_old_power(pos,power)
	end,name,pos,power)
end

local redstone_deactivate = function(name,pos,power)
	minetest.after(0,function(name,pos)
	if minetest.registered_nodes[name].redstone_deactivation then
		minetest.registered_nodes[name].redstone_deactivation(pos)
	end
	set_old_power(pos,power)
	end,name,pos,power)
end

local redstone_update = function(name,pos,power)
	minetest.after(0,function(name,pos,power)
	if minetest.registered_nodes[name].redstone_update then
		minetest.registered_nodes[name].redstone_update(pos)
	end
	set_old_power(pos,power)
	end,name,pos,power)
end





--collect all nodes that are local to the modified
--node of redstone dust and store in memory
function redstone.collect_info(pos)
	--if table.getn(r_index) == 0 then
		--print("-----------------------")
		--print("started indexing")
	--end
	local get_node = minetest.get_node 
	local group = minetest.get_node_group
	
	local function get_group(i,gotten_group)
		return(group(get_node(i).name, gotten_group))
	end
	
	for x = -1,1 do
	for y = -1,1 do
	for z = -1,1 do
		--index only direct neighbors
		if not (math.abs(x)+math.abs(z) > 1) or (math.abs(x)+math.abs(z) == 0) then
			local r_type = ""
			local i = vector.add(pos,vector.new(x,y,z))
			local execute_collection = true
			if r_index[i.x] and r_index[i.x][i.y] then
				if r_index[i.x][i.y][i.z] then
					execute_collection = false
				end
			end
			--[[ EXPLANATION
				we run through the groups
				1 redstone_torch overrides dust if defined
				2 torch_directional overrides torch if defined
				3 redstone activation is bolted on with directional overriding general
				
				this is to prevent weird behavior
				
				
				This new method also uses a table bolted onto the x,y,z positional data value
				what does this mean?
				It's much easier to work with and modify
			]]--		
			
			if execute_collection == true then
				--index dust
				if get_group(i,"redstone_dust") > 0 then
					--add data to both maps
					if not r_index[i.x] then r_index[i.x] = {} end
					if not r_index[i.x][i.y] then r_index[i.x][i.y] = {} end
					r_index[i.x][i.y][i.z] = {dust = true,level = 0} --get_group(i,"redstone_power")}				
					--the data to the 3d array must be written to memory before this is executed
					--or a stack overflow occurs!!!
					--pass down info for activators
					redstone.collect_info(i,get_group(i,"redstone_power"))
				end
				--index power sources
				if get_group(i,"redstone_torch") > 0 then
					if not r_index[i.x] then r_index[i.x] = {} end
					if not r_index[i.x][i.y] then r_index[i.x][i.y] = {} end
					r_index[i.x][i.y][i.z] = {torch = true,power=get_group(i,"redstone_power")}
				end	
				--index directional power sources (Like repeaters/comparators)
				--only outputs forwards
				if get_group(i,"torch_directional") > 0 then
					if not r_index[i.x] then r_index[i.x] = {} end
					if not r_index[i.x][i.y] then r_index[i.x][i.y] = {} end
					r_index[i.x][i.y][i.z] = {torch_directional = true, dir = get_node(i).param2 , power = get_group(i,"redstone_power")}
				end
				
				--index directional activators (Like repeaters/comparators)
				--only accepts input from the back
				if get_group(i,"redstone_activation_directional") > 0 then
					--print("indexing directional")
					if not r_index[i.x] then r_index[i.x] = {} end
					if not r_index[i.x][i.y] then r_index[i.x][i.y] = {} end
					if not r_index[i.x][i.y][i.z] then r_index[i.x][i.y][i.z] = {} end
					--r_index[i.x][i.y][i.z].activate = false
					r_index[i.x][i.y][i.z].redstone_activation = true
					r_index[i.x][i.y][i.z].directional = true
					r_index[i.x][i.y][i.z].dir = get_node(i).param2
				end
				
				--index objects that activate
				if get_group(i,"redstone_activation") > 0 then
					if not r_index[i.x] then r_index[i.x] = {} end
					if not r_index[i.x][i.y] then r_index[i.x][i.y] = {} end
					if not r_index[i.x][i.y][i.z] then r_index[i.x][i.y][i.z] = {} end
					--r_index[i.x][i.y][i.z].activate = false
					r_index[i.x][i.y][i.z].redstone_activation = true
					r_index[i.x][i.y][i.z].name = get_node(i).name
					
					
					--set_powered_state(i)
					
					--local powered = get_powered_state(i)
					
					
					--print("powered:"..powered,"oldpowered:"..old_powered)
								
					--r_index[i.x][i.y][i.z].powered = powered
					--r_index[i.x][i.y][i.z].old_powered = old_powered
					
					--split this into update up and down
					--if  powered > old_powered then
					--	r_index[i.x][i.y][i.z].deactivate = true
					---elseif powered > 0 and old_powered == 0 then
					--	r_index[i.x][i.y][i.z].deactivate = true
					--end
				end
			end
		end
	end
	end
	end
end


--check if index table contains items
--then execute an update
minetest.register_globalstep(function(dtime)
	--if indexes exist then calculate redstone
	if r_index and next(r_index) then
		--create the old version to help with deactivation calculation
		r_copy = table.copy(r_index)
		redstone.calculate()
	end
	--clear the index to avoid cpu looping wasting processing power
	r_index = {}
end)

--make all power sources push power out
function redstone.calculate()
	--pathfind through memory map	
	for x,index_x in pairs(r_index) do
		for y,index_y in pairs(index_x) do
			for z,data in pairs(index_y) do
				--allow data values for torches
				if data.torch then
					redstone.pathfind(vector.new(x,y,z),data.power)
				elseif data.torch_directional then
					redstone.pathfind(vector.new(x,y,z),data.power,data.dir)
				end
			end
		end
	end
		
	--calculate values for voxel manip
	local x_min,x_max,y_min,y_max,z_min,z_max
	for x,index_x in pairs(r_index) do
		for y,index_y in pairs(index_x) do
			for z,_ in pairs(index_y) do
				--do this because the root (x) will always come first
				if not x_min then
					x_min = x
					x_max = x
					y_min = y
					y_max = y
					z_min = z
					z_max = z
				end
				if x < x_min then x_min = x end
				if x > x_max then x_max = x end
				if y < y_min then y_min = y end
				if y > y_max then y_max = y end
				if z < z_min then z_min = z end
				if z > z_max then z_max = z end
			end
		end
	end

	local min = vector.new(x_min,y_min,z_min)
	local max = vector.new(x_max,y_max,z_max)
	local vm = minetest.get_voxel_manip()	
	local emin, emax = vm:read_from_map(min,max)
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()
	local content_id = minetest.get_name_from_content_id
	--reassemble the table into a position list minetest can understand
	
	--run through and set dust
	for x,datax in pairs(r_index) do
		for y,datay in pairs(datax) do
			for z,index in pairs(datay) do
				local p_pos = area:index(x,y,z)	
				if index.dust then
					data[p_pos] = minetest.get_content_id("redstone:dust_"..index.level)
				end
			end
		end
	end
	vm:set_data(data)
	vm:write_to_map()
	
	
	
	--run through activators
	for x,datax in pairs(r_index) do
		for y,datay in pairs(datax) do
			for z,index in pairs(datay) do
				local pos = vector.new(x,y,z)
				local node = minetest.get_node(pos)
				--directional activators
				if index.redstone_activation == true and index.directional == true then
					local power = get_powered_state_directional(pos)
					local old_power = get_old_power(pos)
					if power > 0 and old_power == 0 then
						redstone_activate(node.name,pos,power)
					elseif power == 0 and old_power > 0 then
						redstone_deactivate(node.name,pos,power)
					--do an update if state has not changed
					elseif power > 0 and old_power > 0 then
						redstone_update(node.name,pos,power)
					elseif power == 0 and old_power == 0 then
						redstone_update(node.name,pos,power)
					end
				--non directional activators
				elseif index.redstone_activation == true then
					local power = get_local_power(pos)
					local old_power = get_old_power(pos)
					if power > 0 and old_power == 0 then
						redstone_activate(node.name,pos,power)
					elseif power == 0 and old_power > 0 then
						redstone_deactivate(node.name,pos,power)
					--do an update if state has not changed
					elseif power > 0 and old_power > 0 then
						redstone_update(node.name,pos,power)
					elseif power == 0 and old_power == 0 then
						redstone_update(node.name,pos,power)
					end
				end
			end
		end
	end
end

--make redstone wire pass on current one level lower than it is
function redstone.pathfind(source,source_level,direction)
	--directional torches
	if direction then
		--print("starting direction")
		local dir = minetest.facedir_to_dir(direction)
		local i = vector.add(source,dir)
		if r_index and r_index[i.x] and r_index[i.x][i.y] and r_index[i.x][i.y][i.z] then
			local index = r_index[i.x][i.y][i.z]
			--dust
			if index.dust  then
				local passed_on_level = source_level - 1
				if passed_on_level > 0 then
					r_index[i.x][i.y][i.z].level = passed_on_level
					redstone.pathfind(i,passed_on_level)
				end
			end
		end
	else
		--redstone and torch
		for x = -1,1 do
		for y = -1,1 do
		for z = -1,1 do
			local i = vector.add(source,vector.new(x,y,z))
			if r_index and r_index[i.x] and r_index[i.x][i.y] and r_index[i.x][i.y][i.z] then
				local index = r_index[i.x][i.y][i.z]					
				if index.dust  then
					local passed_on_level = source_level - 1
					if passed_on_level > 0 and index.level < source_level then
						r_index[i.x][i.y][i.z].level = passed_on_level
						redstone.pathfind(i,passed_on_level)
					end
				end
			end
		end
		end
		end
	end
end








----------------------------------------------------------------------------

































minetest.register_craftitem("redstone:dust", {
	description = "Redstone Dust",
	inventory_image = "redstone_dust_item.png",
	wield_image = "redstone_dust_item.png",
	wield_scale = {x = 1, y = 1, z = 1 + 1/16},
	liquids_pointable = false,
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
		
		local _,worked = minetest.item_place(ItemStack("redstone:dust_0"), placer, pointed_thing)
		if worked then
			itemstack:take_item()
			return(itemstack)
		end


			--minetest.add_node(pointed_thing.above, {name="redstone:dust_0"})
			--itemstack:take_item(1)
			--minetest.sound_play("stone", {pos=pointed_thing.above})
			--return(itemstack)
		--end
	end,
})

minetest.register_craft({
	type = "shapeless",
	output = "redstone:dust",
	recipe = {"redstone:dust"},
})

--8 power levels 8 being the highest
local color = 0
for i = 0,8 do
	local coloring = math.floor(color)
	minetest.register_node("redstone:dust_"..i,{
		description = "Redstone Dust",
		wield_image = "redstone_dust_item.png",
		tiles = {
			"redstone_dust_main.png^[colorize:red:"..coloring, "redstone_turn.png^[colorize:red:"..coloring,
			"redstone_t.png^[colorize:red:"..coloring, "redstone_cross.png^[colorize:red:"..coloring
		},
		power=i,
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
		groups={dig_immediate=1,attached_node=1,redstone_dust=1,redstone=1,redstone_power=i},
		drop="redstone:dust",
		on_construct = function(pos)
			redstone.collect_info(pos)
		end,
		after_destruct = function(pos)
			--redstone.remove(pos,minetest.registered_nodes[minetest.get_node(pos).name].power)
			redstone.collect_info(pos,i)
		end,
		connects_to = {"group:redstone"},
	})
	color= color +31.875
end
