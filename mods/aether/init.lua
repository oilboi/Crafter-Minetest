local path = minetest.get_modpath("aether")
dofile(path.."/schem.lua")
dofile(path.."/nodes.lua")
dofile(path.."/biomes.lua")

local aetherportalSchematic = aetherportalSchematic

local
minetest,math,vector,pairs
=
minetest,math,vector,pairs

local abs    = math.abs
local random = math.random

local add_vector   = vector.add
local sub_vector   = vector.subtract
local vec_distance = vector.distance
local new_vector   = vector.new

local t_copy   = table.copy
local t_insert = table.insert
local t_getn   = table.getn

local emerge_area                  = minetest.emerge_area
local get_node                     = minetest.get_node
local find_node_near               = minetest.find_node_near
local find_nodes_in_area_under_air = minetest.find_nodes_in_area_under_air
local place_schematic              = minetest.place_schematic
local bulk_set_node                = minetest.bulk_set_node

local aether_channels = {}
local name
minetest.register_on_joinplayer(function(player)
	name = player:get_player_name()
	aether_channels[name] = minetest.mod_channel_join(name..":aether_teleporters")
end)

--branch out from center
--these are assigned initially for a reason
local a_index = {}
local aether_portal_failure = false
local x_failed = false
local execute_collection
--this can be used globally to create aether portals from obsidian
function create_aether_portal(pos,origin,axis)
	--create the origin node for stored memory
	if not origin then
		origin = pos
		aether_portal_failure = false
	end
	if not axis then
		axis = "x"
	end
		
	--2d virtual memory map creation (x axis)
	if axis == "x" then
		for x = -1,1 do
		for y = -1,1 do
			--index only direct neighbors
			if x_failed == false and (abs(x)+abs(y) == 1) then
				local i = add_vector(pos,new_vector(x,y,0))
				
				execute_collection = true
				
				if a_index[i.x] and a_index[i.x][i.y] then
					if a_index[i.x][i.y][i.z] then
						execute_collection = false
					end
				end	
				
				if execute_collection == true then
					--print(get_node(i).name)
					--index air
					if get_node(i).name == "air" then
						
						if vec_distance(i,origin) < 50 then
							--add data to both maps
							if not a_index[i.x] then a_index[i.x] = {} end
							if not a_index[i.x][i.y] then a_index[i.x][i.y] = {} end
							a_index[i.x][i.y][i.z] = {aether_portal=1} --get_group(i,"redstone_power")}		
							--the data to the 3d array must be written to memory before this is executed
							--or a stack overflow occurs!!!
							--pass down info for activators
							create_aether_portal(i,origin,"x")
						else
							--print("try z")
							x_failed = true
							a_index = {}
							create_aether_portal(origin,origin,"z")
						end
					elseif get_node(i).name ~= "nether:glowstone" then
						x_failed = true
						a_index = {}
						create_aether_portal(origin,origin,"z")
					end
				end
			end
		end
		end
	--2d virtual memory map creation (z axis)
	elseif axis == "z" then
		for z = -1,1 do
		for y = -1,1 do
			--index only direct neighbors
			if x_failed == true and aether_portal_failure == false and (abs(z)+abs(y) == 1) then
				local i = add_vector(pos,new_vector(0,y,z))
				execute_collection = true
				if a_index[i.x] and a_index[i.x][i.y] then
					if a_index[i.x][i.y][i.z] then
						execute_collection = false
					end
				end	
				
				if execute_collection == true then
					--print(get_node(i).name)
					--index air
					if get_node(i).name == "air" then
						if vec_distance(i,origin) < 50 then
							--add data to both maps
							if not a_index[i.x] then a_index[i.x] = {} end
							if not a_index[i.x][i.y] then a_index[i.x][i.y] = {} end
							a_index[i.x][i.y][i.z] = {aether_portal=1}
							--the data to the 3d array must be written to memory before this is executed
							--or a stack overflow occurs!!!
							--pass down info for activators
							create_aether_portal(i,origin,"z")
						else
							aether_portal_failure = true
							a_index = {}
						end
					elseif get_node(i).name ~= "nether:glowstone" then
						aether_portal_failure = true
						a_index = {}
					end
				end
			end
		end
		end
	end
end

--creates a aether portal in the aether
--this essentially makes it so you have to move 30 away from one portal to another otherwise it will travel to an existing portal
local aether_origin_pos = nil
local function spawn_portal_into_aether_callback(blockpos, action, calls_remaining, param)
	if calls_remaining == 0 then
		local portal_exists = find_node_near(aether_origin_pos, 30, {"aether:portal"})
				
		if not portal_exists then
			local min = sub_vector(aether_origin_pos,30)
			local max = add_vector(aether_origin_pos,30)
			local platform = find_nodes_in_area_under_air(min, max, {"aether:dirt","aether:grass"})
			
			if platform and next(platform) then
				--print("setting the platform")
				local platform_location = platform[random(1,t_getn(platform))]
				
				place_schematic(platform_location, aetherportalSchematic,"0",nil,true,"place_center_x, place_center_z")
			else
				--print("generate a portal within aetherrack")
				place_schematic(aether_origin_pos, aetherportalSchematic,"0",nil,true,"place_center_x, place_center_z")
			end
		else
			--print("portal exists, utilizing")
		end
		aether_origin_pos = nil
	end
end
--creates aether portals in the overworld
local function spawn_portal_into_overworld_callback(blockpos, action, calls_remaining, param)
	if calls_remaining == 0 then
		local portal_exists = find_node_near(aether_origin_pos, 30, {"aether:portal"})
				
		if not portal_exists then
			local min = sub_vector(aether_origin_pos,30)
			local max = add_vector(aether_origin_pos,30)
			local platform = find_nodes_in_area_under_air(min, max, {"main:stone","main:water","main:grass","main:sand","main:dirt"})
			
			if platform and next(platform) then
				--print("setting the platform")
				local platform_location = platform[random(1,t_getn(platform))]
				
				place_schematic(platform_location, aetherportalSchematic,"0",nil,true,"place_center_x, place_center_z")
			else
				--print("generate a portal within overworld stone")
				place_schematic(aether_origin_pos, aetherportalSchematic,"0",nil,true,"place_center_x, place_center_z")
			end
		else
			--print("portal exists, utilizing")
		end
		aether_origin_pos = nil
	end
end


local function generate_aether_portal_in_aether(pos)
	if pos.y < 20000 then
		--center the location to the lava height
		pos.y = 25000--+random(-30,30)	
		aether_origin_pos = pos
		
		local min = sub_vector(aether_origin_pos,30)
		local max = add_vector(aether_origin_pos,30)
		
		--force load the area
		emerge_area(min, max, spawn_portal_into_aether_callback)
	else
		--center the location to the water height
		pos.y = 0--+random(-30,30)	
		aether_origin_pos = pos
		--prefer height for mountains
		local min = sub_vector(aether_origin_pos,new_vector(30,30,30))
		local max = add_vector(aether_origin_pos,new_vector(30,120,30))
		
		--force load the area
		emerge_area(min, max, spawn_portal_into_overworld_callback)
	end
end


--modify the map with the collected data
local function portal_modify_map(n_copy)
	local sorted_table = {}
	local created_portal = false
	for x,datax in pairs(n_copy) do
		for y,datay in pairs(datax) do
			for z,index in pairs(datay) do
				--try to create a return side aether portal
				if created_portal == false then
					created_portal = true
					generate_aether_portal_in_aether(new_vector(x,y,z))
				end
				t_insert(sorted_table, new_vector(x,y,z))
			end
		end
	end
	bulk_set_node(sorted_table, {name="aether:portal"})
end

-------------------------------------------------------------------------------------------
--the teleporter parts - stored here for now so I can read from other functions
local teleporting_player = nil
local function teleport_to_overworld(blockpos, action, calls_remaining, param)
	if calls_remaining == 0 then
		local portal_exists = find_node_near(aether_origin_pos, 30, {"aether:portal"})
		if portal_exists then
			--print(teleporting_player)
			if teleporting_player then
				teleporting_player:set_pos(new_vector(portal_exists.x,portal_exists.y-0.5,portal_exists.z))
			end
		end
		teleporting_player = nil
	end
end
local function teleport_to_aether(blockpos, action, calls_remaining, param)
	if calls_remaining == 0 then
		local portal_exists = find_node_near(aether_origin_pos, 30, {"aether:portal"})
		if portal_exists then
			--print(teleporting_player)
			if teleporting_player then
				teleporting_player:set_pos(new_vector(portal_exists.x,portal_exists.y-0.5,portal_exists.z))
			end
		end
		teleporting_player = nil
	end
end

--this initializes all teleporter commands from the client
minetest.register_on_modchannel_message(function(channel_name, sender, message)
	local channel_decyphered = channel_name:gsub(sender,"")
	if channel_decyphered == ":aether_teleporters" then
		local player = minetest.get_player_by_name(sender)
		local pos = player:get_pos()
		
		if pos.y < 20000 then
			--center the location to the lava height
			pos.y = 25000--+random(-30,30)	
			aether_origin_pos = pos
			
			local min = sub_vector(aether_origin_pos,30)
			local max = add_vector(aether_origin_pos,30)
			
			--force load the area
			teleporting_player = player
			emerge_area(min, max, teleport_to_aether)
		else
			--center the location to the water height
			pos.y = 0--+random(-30,30)	
			aether_origin_pos = pos
			--prefer height for mountains
			local min = sub_vector(aether_origin_pos,new_vector(30,30,30))
			local max = add_vector(aether_origin_pos,new_vector(30,120,30))
			
			--force load the area
			teleporting_player = player
			emerge_area(min, max, teleport_to_overworld)
		end
	end
end)
-------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------

local destroy_a_index = {}
local destroy_aether_portal_failure = false
local destroy_aether_portal_failed = false
local execute_collection
--this can be used globally to create aether portals from obsidian
function destroy_aether_portal(pos,origin,axis)
	--create the origin node for stored memory
	if not origin then
		origin = pos
	end		
	--3d virtual memory map creation (x axis)
	for x = -1,1 do
	for z = -1,1 do
	for y = -1,1 do
		--index only direct neighbors
		if (abs(x)+abs(z)+abs(y) == 1) then
			local i = add_vector(pos,new_vector(x,y,z))
			
			execute_collection = true
			
			if destroy_a_index[i.x] and destroy_a_index[i.x][i.y] then
				if destroy_a_index[i.x][i.y][i.z] then
					execute_collection = false
				end
			end	
			
			if execute_collection == true then
				--print(get_node(i).name)
				--index air
				if get_node(i).name == "aether:portal" then
					if vec_distance(i,origin) < 50 then
						--add data to both maps
						if not destroy_a_index[i.x] then destroy_a_index[i.x] = {} end
						if not destroy_a_index[i.x][i.y] then destroy_a_index[i.x][i.y] = {} end
						destroy_a_index[i.x][i.y][i.z] = {aether_portal=1} --get_group(i,"redstone_power")}				
						--the data to the 3d array must be written to memory before this is executed
						--or a stack overflow occurs!!!
						--pass down info for activators
						destroy_aether_portal(i,origin,"z")
					end
				end
			end
		end
	end
	end
	end
end

--modify the map with the collected data
local destroy_sorted_table
local function destroy_portal_modify_map(destroy_n_copy)
	destroy_sorted_table = {}
	for x,datax in pairs(destroy_n_copy) do
		for y,datay in pairs(datax) do
			for z,index in pairs(datay) do
				t_insert(destroy_sorted_table, new_vector(x,y,z))
			end
		end
	end
	bulk_set_node(destroy_sorted_table, {name="air"})
end

minetest.register_globalstep(function(dtime)
	--if indexes exist then calculate redstone
	if a_index and next(a_index) and aether_portal_failure == false then
		--create the old version to help with deactivation calculation
		local n_copy = t_copy(a_index)
		portal_modify_map(n_copy)
		aether_portal_failure = false
	end
	if x_failed == true then
		x_failed = false
	end
	if aether_portal_failure == true then
		aether_portal_failure = false
	end
	--clear the index to avoid cpu looping wasting processing power
	a_index = {}
	
	
	--if indexes exist then calculate redstone
	if destroy_a_index and next(destroy_a_index) and destroy_aether_portal_failure == false then
		--create the old version to help with deactivation calculation
		local destroy_n_copy = t_copy(destroy_a_index)
		destroy_portal_modify_map(destroy_n_copy)
	end
	--clear the index to avoid cpu looping wasting processing power
	destroy_a_index = {}
end)
