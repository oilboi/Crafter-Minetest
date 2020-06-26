local 
minetest,vector,math,table,pairs
=
minetest,vector,math,table,pairs

-- minetest class
local get_node        = minetest.get_node
local get_item_group  = minetest.get_item_group
local get_meta        = minetest.get_meta
local facedir_to_dir  = minetest.facedir_to_dir
local content_id      = minetest.get_name_from_content_id
local get_content_id  = minetest.get_content_id
local get_voxel_manip = minetest.get_voxel_manip
local after           = minetest.after
local registered_nodes
minetest.register_on_mods_loaded(function()
	registered_nodes  = minetest.registered_nodes
end)

-- math class
local abs   = math.abs
local floor = math.floor

-- vector library
local new_vec         = vector.new
local add_vec         = vector.add
local sub_vec         = vector.subtract
local vector_distance = vector.distance

-- redstone class
redstone = {}

local speed_test

local r_index = {}
local a_index = {}

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


--set the data for powered states
local get_local_power = function(pos)
	if not pos then
		return
	end
	for x = -1,1 do
	for y = -1,1 do
	for z = -1,1 do
		--index only direct neighbors
		if abs(x)+abs(z)+abs(y) == 1 then
			--print(get_node(add_vec(new_vec(x,y,z),pos)).name)
			if get_item_group(get_node(add_vec(new_vec(x,y,z),pos)).name, "redstone_power") > 0 then
				return(1)
			end
		end
	end
	end
	end	
	return(0)
end

local get_powered_state_directional = function(pos)
	return(get_item_group(get_node(sub_vec(pos,facedir_to_dir(get_node(pos).param2))).name, "redstone_power"))
end

local node
local redstone_activate = function(pos,power)
	after(0,function()
		node = get_node(pos).name
		if registered_nodes[node].redstone_activation then
			registered_nodes[node].redstone_activation(pos)
		end
	end)
end

local node
local redstone_deactivate = function(pos,power)
	after(0,function()
		node = get_node(pos).name
		if registered_nodes[node].redstone_deactivation then
			registered_nodes[node].redstone_deactivation(pos)
		end
	end)
end

--collect all nodes that are local to the modified
--node of redstone dust and store in memory
local function get_group(i,gotten_group)
	return(get_item_group(get_node(i).name, gotten_group))
end


local localredstone = {}

localredstone.injector = function(i)
	if get_node(i).name == "air" then
		return
	end

	if r_index[i.x] and r_index[i.x][i.y] then
		if r_index[i.x][i.y][i.z] then
			return
		end
	end

	--index dust
	if get_group(i,"redstone_dust") > 0 then
		--add data to both maps
		if not r_index[i.x] then r_index[i.x] = {} end
		if not r_index[i.x][i.y] then r_index[i.x][i.y] = {} end
		r_index[i.x][i.y][i.z] = {dust = true,level = 0}
		--the data to the 3d array must be written to memory before this is executed
		--or a stack overflow occurs!!!
		localredstone.collector(i)
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
		if not a_index[i.x] then a_index[i.x] = {} end
		if not a_index[i.x][i.y] then a_index[i.x][i.y] = {} end
		if not a_index[i.x][i.y][i.z] then a_index[i.x][i.y][i.z] = {} end

		a_index[i.x][i.y][i.z].redstone_activation = true
		a_index[i.x][i.y][i.z].directional = true
	end
	
	--index objects that activate
	if get_group(i,"redstone_activation") > 0 then
		if not a_index[i.x] then a_index[i.x] = {} end
		if not a_index[i.x][i.y] then a_index[i.x][i.y] = {} end
		if not a_index[i.x][i.y][i.z] then a_index[i.x][i.y][i.z] = {} end
		a_index[i.x][i.y][i.z].redstone_activation = true
	end

	--sneaky way to make levers and buttons work
	if get_meta(i):get_int("redstone_power") > 0 then
		if not r_index[i.x] then r_index[i.x] = {} end
		if not r_index[i.x][i.y] then r_index[i.x][i.y] = {} end
		r_index[i.x][i.y][i.z] = {torch = true,power=9}
	end
end

localredstone.collector = function(pos)
	for x = -1,1 do
	for y = -1,1 do
	for z = -1,1 do
		if abs(x)+abs(z) == 1 then
			localredstone.injector(add_vec(pos,new_vec(x,y,z)))
		end
	end
	end
	end
end


function redstone.collect_info(pos)
	localredstone.injector(pos)
	localredstone.collector(pos)
end


--check if index table contains items
--then execute an update
minetest.register_globalstep(function(dtime)
	--if indexes exist then calculate redstone
	if (r_index and next(r_index)) or (a_index and next(a_index)) then
		--create the old version to help with deactivation calculation
		redstone.calculate()
		--clear the index to avoid cpu looping wasting processing power
		r_index = {}
		a_index = {}
	end
end)

--make all power sources push power out
local x_min
local x_max
local y_min
local y_max
local z_min
local z_max
local initial_check


local pos
local node
local power
function redstone.calculate()
	speed_test = minetest.get_us_time()/1000000

	--pathfind through memory map	
	for x,index_x in pairs(r_index) do
		for y,index_y in pairs(index_x) do
			for z,data in pairs(index_y) do
				--allow data values for torches
				if data.torch then
					redstone.pathfind(new_vec(x,y,z),data.power)
					r_index[x][y][z] = nil
				elseif data.torch_directional then
					redstone.pathfind(new_vec(x,y,z),data.power,data.dir)
					r_index[x][y][z] = nil
				end
			end
		end
	end
	
	print("total torch calc time:"..minetest.get_us_time()/1000000-speed_test)



	--reassemble the table into a position list minetest can understand
	--run through and set dust
	for x,datax in pairs(r_index) do
		for y,datay in pairs(datax) do
			for z,index in pairs(datay) do
				--print(get_node(new_vec(x,y,z)).name)
				if index and index.dust then
					minetest.set_node(new_vec(x,y,z),{name="redstone:dust_"..index.level})
				end
			end
		end
	end

	for x,datax in pairs(a_index) do
		for y,datay in pairs(datax) do
			for z,index in pairs(datay) do
				--directional activators
				if index.directional == true then
					power = get_powered_state_directional(new_vec(x,y,z))
					if power then
						if power > 0 then
							redstone_activate(new_vec(x,y,z),power)
						elseif power == 0 then
							redstone_deactivate(new_vec(x,y,z),power)
						end
					end
				--non directional activators
				else
					power = get_local_power(new_vec(x,y,z))
					if power then
						if power > 0 then
							redstone_activate(new_vec(x,y,z),power)
						elseif power == 0 then
							redstone_deactivate(new_vec(x,y,z),power)
						end
					end
				end
			end
		end
	end
end

--make redstone wire pass on current one level lower than it is
local i
local index
local passed_on_level
local function redstone_pathfinder(source,source_level,direction)
	--directional torches

	if direction then
		--print("starting direction")
		i = add_vec(source,facedir_to_dir(direction))
		if r_index and r_index[i.x] and r_index[i.x][i.y] and r_index[i.x][i.y][i.z] then
			index = r_index[i.x][i.y][i.z]
			--dust
			if index.dust  then
				passed_on_level = source_level - 1
				if passed_on_level > 0 then
					r_index[i.x][i.y][i.z].level = passed_on_level
					redstone_pathfinder(i,passed_on_level,nil,origin)
				end
			end
		end
	else
		--redstone and torch
		for x = -1,1 do
		for y = -1,1 do
		for z = -1,1 do
			if abs(x)+abs(z) == 1 then
				i = add_vec(source,new_vec(x,y,z))
				if r_index and r_index[i.x] and r_index[i.x][i.y] and r_index[i.x][i.y][i.z] then
					index = r_index[i.x][i.y][i.z]					
					if index.dust  then
						passed_on_level = source_level - 1
						if passed_on_level > 0 and index.level < source_level then
							r_index[i.x][i.y][i.z].level = passed_on_level
							redstone_pathfinder(i,passed_on_level,nil)
						end
					end
				end
			end
		end
		end
		end
	end
end
function redstone.pathfind(source,source_level,direction)
	redstone_pathfinder(source,source_level,direction)
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
		local noddef = registered_nodes[get_node(pointed_thing.under).name]
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

--8 power levels 8 being the highest
local color = 0
for i = 0,8 do
	local coloring = floor(color)
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
			--redstone.remove(pos,registered_nodes[get_node(pos).name].power)
			redstone.collect_info(pos)
		end,
		connects_to = {"group:redstone"},
	})
	color= color +31.875
end
