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

							if x == pos.x-9 or x == pos.x+9 or 
							y == pos.y-9 or y == pos.y+9 or 
							z == pos.z-9 or z == pos.z+9 then
								if temp_pool.dust then
									table_3d[x][y][z] = {torch=temp_pool.dust}
								else
									table_3d[x][y][z] = temp_pool
								end
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


-- redstone class
redstone = {}

local path = minetest.get_modpath("redstone")
--dofile(path.."/functions.lua")
--dofile(path.."/wire.lua")
dofile(path.."/torch.lua")
--dofile(path.."/lever.lua")
--dofile(path.."/button.lua")
--dofile(path.."/repeater.lua")
--dofile(path.."/light.lua")
--dofile(path.."/piston.lua")
--dofile(path.."/comparator.lua")
--dofile(path.."/craft.lua")
--dofile(path.."/ore.lua")
--dofile(path.."/inverter.lua")
--dofile(path.."/player_detector.lua")
--dofile(path.."/space_maker.lua")
--dofile(path.."/pressure_plate.lua")


--make redstone wire pass on current one level lower than it is
local i
local index
local passed_on_level
local function redstone_pathfinder(source,source_level,boundary,direction)
	--directional torches
	if direction then
		i = add_vec(source,facedir_to_dir(direction))
		if boundary and boundary[i.x][i.y][i.z] then
			index = boundary[i.x][i.y][i.z]
			--dust
			if index.dust then
				passed_on_level = source_level - 1
				if passed_on_level > 0 then
					boundary[i.x][i.y][i.z].dust = passed_on_level
					redstone_pathfinder(i,passed_on_level,boundary,nil)
				end
			end
		end
	else
		--redstone and torch
		for _,order in pairs(order) do
			i = add_vec(source,new_vec(order.x,order.y,order.z))
			if i and boundary and boundary[i.x] and boundary[i.x][i.y] and boundary[i.x][i.y][i.z] then
				index = boundary[i.x][i.y][i.z]

				if index.dust then

					passed_on_level = source_level - 1

					if passed_on_level > 0 and index.dust < source_level then
						boundary[i.x][i.y][i.z].dust = passed_on_level

						redstone_pathfinder(i,passed_on_level,boundary,nil)

					end
				end
			end
		end
	end
	return(boundary)
end


--make all power sources push power out
local pos
local node
local power

local boundary
local function calculate(pos)

	boundary = create_boundary_box(pos)

	--pathfind through memory map	
	for x,index_x in pairs(boundary) do
		for y,index_y in pairs(index_x) do
			for z,data in pairs(index_y) do
				--allow data values for torches
				if data.torch then
					redstone_pathfinder(new_vec(x,y,z),data.torch,boundary)
					boundary[x][y][z] = nil
				elseif data.torch_directional then
					redstone_pathfinder(new_vec(x,y,z),data.torch,boundary,data.dir)
					boundary[x][y][z] = nil
				end
			end
		end
	end

	--reassemble the table into a position list minetest can understand
	--run through and set dust
	for x,datax in pairs(boundary) do
		for y,datay in pairs(datax) do
			for z,data in pairs(datay) do
				--print(dump(data))
				if data.dust and data.dust ~= data.origin then
					--print("setting:" ..data.dust)
					swap_node(new_vec(x,y,z),{name="redstone:dust_"..data.dust})
				end
			end
		end
	end
	--[[
	for x,datax in pairs(boundary) do
		for y,datay in pairs(datax) do
			for z,data in pairs(datay) do
				--directional activators
				if data.directional == true then
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
					--print(power)
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
	]]--

	for x,index_x in pairs(boundary) do
		for y,index_y in pairs(index_x) do
			for z,data in pairs(index_y) do
				--write data back to memory pool
				pool[x][y][z] = data
			end
		end
	end
end


function redstone.inject(pos,data)
	data_injection(pos,data)
end


function redstone.update(pos)
	calculate(pos)
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
