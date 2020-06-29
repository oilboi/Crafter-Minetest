local 
minetest,vector,math,table,pairs,next
=
minetest,vector,math,table,pairs,next

-- minetest class
local get_node        = minetest.get_node
local get_item_group  = minetest.get_item_group
local get_meta        = minetest.get_meta
local facedir_to_dir  = minetest.facedir_to_dir
local content_id      = minetest.get_name_from_content_id
local get_content_id  = minetest.get_content_id
local get_voxel_manip = minetest.get_voxel_manip
local after           = minetest.after

local swap_node       = minetest.swap_node
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
local vec_equals      = vector.equals

local activator_table = {} -- this holds the translation data of activator tables (activator functions)
local capacitor_table = {}

-- redstone class
redstone = {}

-- enables mods to create data functions
function redstone.register_activator(data)
	activator_table[data.name] = {
		activate   = data.activate,
		deactivate = data.deactivate
	}
end

-- enables mods to create data functions
function redstone.register_capacitor(data)
	capacitor_table[data.name] = {
		off = data.off,
		on  = data.on
	}
end

local path = minetest.get_modpath("redstone")
dofile(path.."/functions.lua")
--dofile(path.."/wire.lua")
dofile(path.."/torch.lua")
dofile(path.."/lever.lua")
dofile(path.."/button.lua")
dofile(path.."/repeater.lua")
dofile(path.."/light.lua")
dofile(path.."/piston.lua")
--dofile(path.."/comparator.lua")
dofile(path.."/craft.lua")
--dofile(path.."/ore.lua")
dofile(path.."/inverter.lua")
--dofile(path.."/player_detector.lua")
dofile(path.."/space_maker.lua")
--dofile(path.."/pressure_plate.lua")
dofile(path.."/capacitors.lua")


--this is written out manually so that
--math.abs is not needed
local order = {
	{x=1, y=0, z=0}, {x=-1, y=0, z= 0},
	{x=0, y=0, z=1}, {x= 0, y=0, z=-1},

	{x=0, y=1, z=0}, {x= 0, y=-1, z=0},

	{x=1, y=1, z=0}, {x=-1, y=1, z= 0},
	{x=0, y=1, z=1}, {x= 0, y=1, z=-1},

	{x=1, y=-1, z=0}, {x=-1, y=-1, z= 0},
	{x=0, y=-1, z=1}, {x= 0, y=-1, z=-1},
}

--thanks to RhodiumToad for helping me figure out a good method to do this

local pool = {} -- this holds all redstone data (literal 3d virtual memory map)


local function data_injection(pos,data)
	-- add data into 3d memory
	if data then
		if not pool[pos.x] then pool[pos.x] = {} end
		if not pool[pos.x][pos.y] then pool[pos.x][pos.y] = {} end
		pool[pos.x][pos.y][pos.z] = data
	--delete data from 3d memory
	else
		if pool and pool[pos.x] and pool[pos.x][pos.y] then
			pool[pos.x][pos.y][pos.z] = data
			if pool[pos.x][pos.y] and not next(pool[pos.x][pos.y]) then
				pool[pos.x][pos.y] = nil
				-- only run this if y axis is empty
				if pool[pos.x] and not next(pool[pos.x]) then
					pool[pos.x] = nil
				end
			end
		end
	end
end

local table_3d
local temp_pool
local function create_boundary_box(pos)
	table_3d = {}
	for x = pos.x-9,pos.x+9 do
		if pool[x] then
			for y = pos.y-9,pos.y+9 do
				if pool[x][y] then
					for z = pos.z-9,pos.z+9 do
						temp_pool = pool[x][y][z]
						if temp_pool then
							if not table_3d[x] then table_3d[x] = {} end
							if not table_3d[x][y] then table_3d[x][y] = {} end

							if (x == pos.x-9 or x == pos.x+9 or 
							y == pos.y-9 or y == pos.y+9 or 
							z == pos.z-9 or z == pos.z+9) and 
							temp_pool.dust and temp_pool.dust > 1 then
								table_3d[x][y][z] = {torch=temp_pool.dust}
							else
								if temp_pool.dust then
									table_3d[x][y][z] = {dust=0,origin=temp_pool.dust}
								else
									table_3d[x][y][z] = temp_pool
								end
							end
						end
					end
				end
			end
		end
	end
	return(table_3d)
end

local i
local index
local function capacitor_pathfind(source,mem_map)
	for _,order in pairs(order) do

		i = add_vec(source,order)
		if not mem_map[i.x] then mem_map[i.x] = {} end
		if not mem_map[i.x][i.y] then mem_map[i.x][i.y] = {} end

		if not mem_map[i.x][i.y][i.z] then

			if i and pool and pool[i.x] and pool[i.x][i.y] and pool[i.x][i.y][i.z] then
				index = pool[i.x][i.y][i.z]
				if index.capacitor then
					mem_map[i.x][i.y][i.z] = {name = index.name, capacitor = 0, source = index.source}
					if index.source then
						mem_map.found = true
					end
					capacitor_pathfind(i,mem_map)
				end
			end
		end
	end
	return mem_map
end

local table_3d
local found
local temp_pool
local function capacitor_sniff(pos)
	table_3d = {}
	table_3d = capacitor_pathfind(pos,table_3d)
	found = table_3d.found
	table_3d.found = nil
	if found then
		for x,datax in pairs(table_3d) do
			for y,datay in pairs(datax) do
				for z,data in pairs(datay) do
					temp_pool = pool[x][y][z]
					if temp_pool then
						temp_pool.capacitor = 1
						if capacitor_table[temp_pool.name] then
							swap_node(new_vec(x,y,z),{name=capacitor_table[temp_pool.name].on})
							redstone.update(new_vec(x,y,z))
						end
					end
				end
			end
		end
	else
		for x,datax in pairs(table_3d) do
			for y,datay in pairs(datax) do
				for z,data in pairs(datay) do
					temp_pool = pool[x][y][z]
					if temp_pool then
						temp_pool.capacitor = 0
						if capacitor_table[temp_pool.name] then
							swap_node(new_vec(x,y,z),{name=capacitor_table[temp_pool.name].off})
							redstone.update(new_vec(x,y,z))
						end
					end
				end
			end
		end
	end
end



-- activators
local n_pos
local temp_pool
local temp_pool2
local non_directional_activator = function(pos)
	if pool[pos.x] and pool[pos.x][pos.y] and pool[pos.x][pos.y][pos.z] then
		temp_pool = pool[pos.x][pos.y][pos.z]
		for _,order in pairs(order) do
			n_pos = add_vec(pos,order)
			if pool[n_pos.x] and pool[n_pos.x][n_pos.y] and pool[n_pos.x][n_pos.y][n_pos.z] then
				temp_pool2 = pool[n_pos.x][n_pos.y][n_pos.z]
				if temp_pool2 then
					if (not temp_pool2.directional_activator and temp_pool2.torch) or 
					(temp_pool2.dust and temp_pool2.dust > 0) or 
					(temp_pool2.torch_directional and vector.equals(temp_pool2.output, pos)) then
						if activator_table[temp_pool.name].activate then
							activator_table[temp_pool.name].activate(pos)
						end
						return
					end
				end
			end
		end	
		if activator_table[temp_pool.name].deactivate then
			activator_table[temp_pool.name].deactivate(pos)
		end
	end
end

-- directional activators
local n_pos
local temp_pool
local temp_pool2
local input
local ignore
local directional_activator = function(pos)
	
	ignore = false
	input = nil
	temp_pool2 = nil

	temp_pool = pool[pos.x][pos.y][pos.z]
	
	if not temp_pool then ignore = true end

	if not ignore then
		input = temp_pool.input
	end

	if not input then ignore = true end

	if not ignore then
		input = temp_pool.input
	end

	if not ignore and pool and pool[input.x] and pool[input.x][input.y] and pool[input.x][input.y][input.z] then
		temp_pool2 = pool[input.x][input.y][input.z]
	else
		ignore = true
	end

	if not temp_pool2 then ignore = true end

	if not ignore and ((temp_pool2.dust and temp_pool2.dust > 0) or (temp_pool2.torch and temp_pool2.directional_activator and temp_pool2.dir == temp_pool.dir) or 
	(not temp_pool2.directional_activator and temp_pool2.torch) or (temp_pool2.capacitor and temp_pool2.capacitor > 0))  then
		if activator_table[temp_pool.name].activate then
			activator_table[temp_pool.name].activate(pos)
			return
		end
		return
	end

	if activator_table[temp_pool.name].deactivate then
		activator_table[temp_pool.name].deactivate(pos)
	end
end

--make redstone wire pass on current one level lower than it is
local i
local index
local passed_on_level
local function redstone_pathfinder(source,source_level,mem_map,output)
	if not source_level then return end
	--directional torches
	if output then
		i = output
		if i and mem_map and mem_map[i.x] and mem_map[i.x][i.y] and mem_map[i.x][i.y][i.z] then
			index = mem_map[i.x][i.y][i.z]
			--dust
			if index.dust then
				passed_on_level = source_level - 1
				if passed_on_level > 0 then
					mem_map[i.x][i.y][i.z].dust = passed_on_level
					redstone_pathfinder(i,passed_on_level,mem_map,nil)
				end
			end
		end
	else
		--redstone and torch
		for _,order in pairs(order) do
			i = add_vec(source,order)
			if i and mem_map and mem_map[i.x] and mem_map[i.x][i.y] and mem_map[i.x][i.y][i.z] then
				index = mem_map[i.x][i.y][i.z]
				if index.dust then
					passed_on_level = source_level - 1
					if passed_on_level > 0 and index.dust < source_level then
						mem_map[i.x][i.y][i.z].dust = passed_on_level
						redstone_pathfinder(i,passed_on_level,mem_map,nil)
					end
				end
			end
		end
	end
	return(mem_map)
end


--[[
                     , 
                ,.  | \ 
               |: \ ; :\ 
               :' ;\| ::\ 
                \ : | `::\ 
                _)  |   `:`. 
              ,' , `.    ;: ; 
            ,' ;:  ;"'  ,:: |_ 
           /,   ` .    ;::: |:`-.__ 
        _,' _o\  ,::.`:' ;  ;   . ' 
    _,-'           `:.          ;""\, 
 ,-'                     ,:         `-;, 
 \,                       ;:           ;--._ 
  `.______,-,----._     ,' ;:        ,/ ,  ,` 
         / /,-';'  \     ; `:      ,'/,::.::: 
       ,',;-'-'_,--;    ;   :.   ,',',;:::::: 
      ( /___,-'     `.     ;::,,'o/  ,::::::: 
       `'             )    ;:,'o /  ;"-   -:: 
                      \__ _,'o ,'         ,:: 
                         ) `--'       ,..:::: 
                         ; `.        ,::::::: 
                          ;  ``::.    ::::::: 
]]-- sic em boy!
local i
local index
local function dust_sniff(pos,mem_map,boundary)
	for _,order in pairs(order) do
		i = add_vec(pos,order)

		if not mem_map[i.x] then mem_map[i.x] = {} end
		if not mem_map[i.x][i.y] then mem_map[i.x][i.y] = {} end

		if not mem_map[i.x][i.y][i.z] then
			if i and boundary and boundary[i.x] and boundary[i.x][i.y] and boundary[i.x][i.y][i.z] then
				index = boundary[i.x][i.y][i.z]
				if index.dust then
					mem_map[i.x][i.y][i.z] = index
					mem_map[i.x][i.y][i.z].sniffed = true

					dust_sniff(i,mem_map,boundary)

				elseif index.torch and index.torch > 1 then
					if index.torch_directional and vec_equals(pos,index.output) then
						mem_map[i.x][i.y][i.z] = index
						mem_map[i.x][i.y][i.z].sniffed = true
					elseif not index.torch_directional then
						mem_map[i.x][i.y][i.z] = index
						mem_map[i.x][i.y][i.z].sniffed = true
					end
				elseif index.activator then
					mem_map[i.x][i.y][i.z] = index
					mem_map[i.x][i.y][i.z].sniffed = true
				end
				--this needs to be hooked into the end
				--because nodes can be directional activators
				--and directional torches
				if index.directional_activator and vec_equals(pos,index.input) then
					mem_map[i.x][i.y][i.z] = index
					mem_map[i.x][i.y][i.z].sniffed = true
				end
			end
		end
	end
	return mem_map
end

--make all power sources push power out
local pos
local node
local power
local boundary
local dust_detected
local dust_map
local count
local pos3
local temp_pool3
local function calculate(pos,is_capacitor)
	if not is_capacitor then
		boundary = create_boundary_box(pos)
		dust_map = {}

		dust_detected = false
		count = 0
		
		--update needs to sniff it's own position
		if boundary[pos.x] and boundary[pos.x][pos.y] and boundary[pos.x][pos.y][pos.z] then
			if not dust_map[pos.x] then dust_map[pos.x] = {} end
			if not dust_map[pos.x][pos.y] then dust_map[pos.x][pos.y] = {} end
			dust_map[pos.x][pos.y][pos.z] = boundary[pos.x][pos.y][pos.z]
		end

		dust_sniff(pos,dust_map,boundary)

		-- sniff all possible dust within boundaries
		for _,pos2 in pairs(order) do
			pos3 = add_vec(pos,pos2)
			if boundary[pos3.x] and boundary[pos3.x][pos3.y] and boundary[pos3.x][pos3.y][pos3.z] and
				not (dust_map[pos3.x] and dust_map[pos3.x][pos3.y] and dust_map[pos3.x][pos3.y][pos3.z] and dust_map[pos3.x][pos3.y][pos3.z].sniffed) then
				temp_pool3 = boundary[pos3.x][pos3.y][pos3.z]
				if temp_pool3.dust then
					dust_sniff(pos3,dust_map,boundary)
				end
			end
		end


		--do torches
		for x,datax in pairs(dust_map) do
			for y,datay in pairs(datax) do
				for z,data in pairs(datay) do
					count = count + 1
					if data.torch then
						if data.torch_directional then
							redstone_pathfinder(new_vec(x,y,z),data.torch,dust_map,data.output)
						else
							redstone_pathfinder(new_vec(x,y,z),data.torch,dust_map)
							dust_map[x][y][z] = nil
						end
					end
				end
			end
		end

		--set dust, set pool memory
		for x,datax in pairs(dust_map) do
			for y,datay in pairs(datax) do
				for z,data in pairs(datay) do
					--print("update")
					if data.dust and data.dust ~= data.origin then
						swap_node(new_vec(x,y,z),{name="redstone:dust_"..data.dust})
					end
					--write data back to memory pool
					pool[x][y][z] = data

					if data.dust then
						--delete the data to speed up next loop
						dust_map[x][y][z] = nil
					end
				end
			end
		end

		--activators
		--this must be run at the end
		for x,datax in pairs(dust_map) do
			for y,datay in pairs(datax) do
				for z,data in pairs(datay) do
					if data.directional_activator then
						directional_activator(new_vec(x,y,z))
					elseif data.activator then
						non_directional_activator(new_vec(x,y,z))
					end
				end
			end
		end
	else
		capacitor_sniff(pos)
	end
end


function redstone.inject(pos,data)
	data_injection(pos,data)
end


local recursion_check = {}
local bad_node
function redstone.update(pos,is_capacitor)
	local s_pos = minetest.serialize(pos)
	if not recursion_check[s_pos] then
		recursion_check[s_pos] = 0
	end
	recursion_check[s_pos] = recursion_check[s_pos] + 1
	if recursion_check[s_pos] > 25 then
		--print(recursion_check[s_pos])
		minetest.after(0,function()
			bad_node = minetest.get_node(pos).name
			bad_node = minetest.get_node_drops(bad_node, "main:rubypick")
			for _,nodey in pairs(bad_node) do
				minetest.throw_item(pos,nodey)
			end
			minetest.dig_node(pos)
			data_injection(pos,nil)
			redstone.update(pos)
		end)
		return
	end

	calculate(pos,is_capacitor)
end

minetest.register_globalstep(function()
	recursion_check = {}
end)


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
			data_injection(pos,{dust=i})
			calculate(pos)
		end,
		after_destruct = function(pos)
			data_injection(pos,nil)
			calculate(pos)
		end,
		connects_to = {"group:redstone"},
	})
	color= color +31.875

	minetest.register_lbm({
        name = "redstone:"..i,
		nodenames = {"redstone:dust_"..i},
		run_at_every_load = true,
        action = function(pos)
            data_injection(pos,{dust=i})
        end,
    })
end
