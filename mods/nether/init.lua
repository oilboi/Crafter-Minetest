local nether_channels = {}

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	nether_channels[name] = minetest.mod_channel_join(name..":nether_teleporters")
end)

local path = minetest.get_modpath("nether")
dofile(path.."/schem.lua")
dofile(path.."/nodes.lua")
dofile(path.."/biomes.lua")
dofile(path.."/craft_recipes.lua")
dofile(path.."/ore.lua")
dofile(path.."/items.lua")


minetest.register_node("nether:portal", {
	description = "Nether Portal",

	tiles = {
		{
			name = "nether_portal.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5,
			},
		},
		{
			name = "nether_portal.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5,
			},
		},
	},
	drawtype = "nodebox",
	paramtype = "light",
	--paramtype2 = "facedir",
	sunlight_propagates = true,
	use_texture_alpha = false,
	walkable = false,
	diggable = false,
	pointable = false,
	buildable_to = false,
	is_ground_content = false,
	drop = "",
	light_source = 7,
	--post_effect_color = {a = 180, r = 51, g = 7, b = 89},
	alpha = 140,
	node_box = {
	type = "connected",
		-- connect_top =
		-- connect_bottom =
		connect_front = {0,  -1/2, -1/2,   0,  1/2, 0 },
		connect_left =  {-1/2,   -1/2, 0, 0,   1/2,  0},
		connect_back =  {0,  -1/2,  0,   0,  1/2,  1/2 },
		connect_right = { 0,   -1/2, 0,  1/2,   1/2,  0},
	},
	connects_to = {"nether:portal","nether:obsidian"},
	groups = {unbreakable=1},
	--on_destruct = destroy_portal,
})

--branch out from center
local n_index = {}
local portal_failure = false
local x_failed = false

--this can be used globally to create nether portals from obsidian
function create_nether_portal(pos,origin,axis)
	--create the origin node for stored memory
	if not origin then
		origin = pos
		portal_failure = false
	end
	if not axis then
		axis = "x"
	end
		
	--2d virtual memory map creation (x axis)
	if axis == "x" then
		for x = -1,1 do
		for y = -1,1 do
			--index only direct neighbors
			if x_failed == false and (math.abs(x)+math.abs(y) == 1) then
				local i = vector.add(pos,vector.new(x,y,0))
				
				local execute_collection = true
				
				if n_index[i.x] and n_index[i.x][i.y] then
					if n_index[i.x][i.y][i.z] then
						execute_collection = false
					end
				end	
				
				if execute_collection == true then
					--print(minetest.get_node(i).name)
					--index air
					if minetest.get_node(i).name == "air" then
						
						if vector.distance(i,origin) < 50 then
							--add data to both maps
							if not n_index[i.x] then n_index[i.x] = {} end
							if not n_index[i.x][i.y] then n_index[i.x][i.y] = {} end
							n_index[i.x][i.y][i.z] = {nether_portal=1} --get_group(i,"redstone_power")}		
							--the data to the 3d array must be written to memory before this is executed
							--or a stack overflow occurs!!!
							--pass down info for activators
							create_nether_portal(i,origin,"x")
						else
							--print("try z")
							x_failed = true
							n_index = {}
							create_nether_portal(origin,origin,"z")
						end
					elseif minetest.get_node(i).name ~= "nether:obsidian" then
						x_failed = true
						n_index = {}
						create_nether_portal(origin,origin,"z")
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
			if x_failed == true and portal_failure == false and (math.abs(z)+math.abs(y) == 1) then
				local i = vector.add(pos,vector.new(0,y,z))
				
				local execute_collection = true
				
				if n_index[i.x] and n_index[i.x][i.y] then
					if n_index[i.x][i.y][i.z] then
						execute_collection = false
					end
				end	
				
				if execute_collection == true then
					--print(minetest.get_node(i).name)
					--index air
					if minetest.get_node(i).name == "air" then
						if vector.distance(i,origin) < 50 then
							--add data to both maps
							if not n_index[i.x] then n_index[i.x] = {} end
							if not n_index[i.x][i.y] then n_index[i.x][i.y] = {} end
							n_index[i.x][i.y][i.z] = {nether_portal=1} --get_group(i,"redstone_power")}				
							--the data to the 3d array must be written to memory before this is executed
							--or a stack overflow occurs!!!
							--pass down info for activators
							create_nether_portal(i,origin,"z")
						else
							--print("portal failed")
							portal_failure = true
							n_index = {}
							--print("try z")
						end
					elseif minetest.get_node(i).name ~= "nether:obsidian" then
						--print("portal failed")
						portal_failure = true
						n_index = {}
					end
				end
			end
		end
		end
	end
end

--creates a nether portal in the nether
--this essentially makes it so you have to move 30 away from one portal to another otherwise it will travel to an existing portal
local nether_origin_pos = nil
local function spawn_portal_into_nether_callback(blockpos, action, calls_remaining, param)
	if calls_remaining == 0 then
		local portal_exists = minetest.find_node_near(nether_origin_pos, 30, {"nether:portal"})
				
		if not portal_exists then
			local min = vector.subtract(nether_origin_pos,30)
			local max = vector.add(nether_origin_pos,30)
			local platform = minetest.find_nodes_in_area_under_air(min, max, {"nether:netherrack","main:lava"})
			
			if platform and next(platform) then
				--print("setting the platform")
				local platform_location = platform[math.random(1,table.getn(platform))]
				
				minetest.place_schematic(platform_location, portalSchematic,"0",nil,true,"place_center_x, place_center_z")
			else
				--print("generate a portal within netherrack")
				minetest.place_schematic(nether_origin_pos, portalSchematic,"0",nil,true,"place_center_x, place_center_z")
			end
		else
			--print("portal exists, utilizing")
		end
		nether_origin_pos = nil
	end
end
--creates nether portals in the overworld
local function spawn_portal_into_overworld_callback(blockpos, action, calls_remaining, param)
	if calls_remaining == 0 then
		local portal_exists = minetest.find_node_near(nether_origin_pos, 30, {"nether:portal"})
				
		if not portal_exists then
			local min = vector.subtract(nether_origin_pos,30)
			local max = vector.add(nether_origin_pos,30)
			local platform = minetest.find_nodes_in_area_under_air(min, max, {"main:stone","main:water","main:grass","main:sand","main:dirt"})
			
			if platform and next(platform) then
				--print("setting the platform")
				local platform_location = platform[math.random(1,table.getn(platform))]
				
				minetest.place_schematic(platform_location, portalSchematic,"0",nil,true,"place_center_x, place_center_z")
			else
				--print("generate a portal within overworld stone")
				minetest.place_schematic(nether_origin_pos, portalSchematic,"0",nil,true,"place_center_x, place_center_z")
			end
		else
			--print("portal exists, utilizing")
		end
		nether_origin_pos = nil
	end
end


local function generate_nether_portal_in_nether(pos)
	if pos.y > -10033 then
		--center the location to the lava height
		pos.y = -15000--+math.random(-30,30)	
		nether_origin_pos = pos
		
		local min = vector.subtract(nether_origin_pos,30)
		local max = vector.add(nether_origin_pos,30)
		
		--force load the area
		minetest.emerge_area(min, max, spawn_portal_into_nether_callback)
	else
		--center the location to the water height
		pos.y = 0--+math.random(-30,30)	
		nether_origin_pos = pos
		--prefer height for mountains
		local min = vector.subtract(nether_origin_pos,vector.new(30,30,30))
		local max = vector.add(nether_origin_pos,vector.new(30,120,30))
		
		--force load the area
		minetest.emerge_area(min, max, spawn_portal_into_overworld_callback)
	end
end


--modify the map with the collected data
local function portal_modify_map(n_copy)
	local sorted_table = {}
	local created_portal = false
	for x,datax in pairs(n_copy) do
		for y,datay in pairs(datax) do
			for z,index in pairs(datay) do
				--try to create a return side nether portal
				if created_portal == false then
					created_portal = true
					generate_nether_portal_in_nether(vector.new(x,y,z))
				end
				table.insert(sorted_table, vector.new(x,y,z))
			end
		end
	end
	minetest.bulk_set_node(sorted_table, {name="nether:portal"})
end

-------------------------------------------------------------------------------------------
--the teleporter parts - stored here for now so I can read from other functions
local teleporting_player = nil
local function teleport_to_overworld(blockpos, action, calls_remaining, param)
	if calls_remaining == 0 then
		local portal_exists = minetest.find_node_near(nether_origin_pos, 30, {"nether:portal"})
		if portal_exists then
			--print(teleporting_player)
			if teleporting_player then
				teleporting_player:set_pos(vector.new(portal_exists.x,portal_exists.y-0.5,portal_exists.z))
			end
		end
		teleporting_player = nil
	end
end
local function teleport_to_nether(blockpos, action, calls_remaining, param)
	if calls_remaining == 0 then
		local portal_exists = minetest.find_node_near(nether_origin_pos, 30, {"nether:portal"})
		if portal_exists then
			--print(teleporting_player)
			if teleporting_player then
				teleporting_player:set_pos(vector.new(portal_exists.x,portal_exists.y-0.5,portal_exists.z))
			end
		end
		teleporting_player = nil
	end
end

--this initializes all teleporter commands from the client
minetest.register_on_modchannel_message(function(channel_name, sender, message)
	local channel_decyphered = channel_name:gsub(sender,"")
	if channel_decyphered == ":nether_teleporters" then
		local player = minetest.get_player_by_name(sender)
		local pos = player:get_pos()
		
		if pos.y > -10033 then
			--center the location to the lava height
			pos.y = -15000--+math.random(-30,30)	
			nether_origin_pos = pos
			
			local min = vector.subtract(nether_origin_pos,30)
			local max = vector.add(nether_origin_pos,30)
			
			--force load the area
			teleporting_player = player
			minetest.emerge_area(min, max, teleport_to_nether)
		else
			--center the location to the water height
			pos.y = 0--+math.random(-30,30)	
			nether_origin_pos = pos
			--prefer height for mountains
			local min = vector.subtract(nether_origin_pos,vector.new(30,30,30))
			local max = vector.add(nether_origin_pos,vector.new(30,120,30))
			
			--force load the area
			teleporting_player = player
			minetest.emerge_area(min, max, teleport_to_overworld)
		end
	end
end)
-------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------

local destroy_n_index = {}
local destroy_portal_failure = false
local destroy_x_failed = false

--this can be used globally to create nether portals from obsidian
function destroy_nether_portal(pos,origin,axis)
	--create the origin node for stored memory
	if not origin then
		origin = pos
	end		
	--3d virtual memory map creation (x axis)
	for x = -1,1 do
	for z = -1,1 do
	for y = -1,1 do
		--index only direct neighbors
		if (math.abs(x)+math.abs(z)+math.abs(y) == 1) then
			local i = vector.add(pos,vector.new(x,y,z))
			
			local execute_collection = true
			
			if destroy_n_index[i.x] and destroy_n_index[i.x][i.y] then
				if destroy_n_index[i.x][i.y][i.z] then
					execute_collection = false
				end
			end	
			
			if execute_collection == true then
				--print(minetest.get_node(i).name)
				--index air
				if minetest.get_node(i).name == "nether:portal" then
					if vector.distance(i,origin) < 50 then
						--add data to both maps
						if not destroy_n_index[i.x] then destroy_n_index[i.x] = {} end
						if not destroy_n_index[i.x][i.y] then destroy_n_index[i.x][i.y] = {} end
						destroy_n_index[i.x][i.y][i.z] = {nether_portal=1} --get_group(i,"redstone_power")}				
						--the data to the 3d array must be written to memory before this is executed
						--or a stack overflow occurs!!!
						--pass down info for activators
						destroy_nether_portal(i,origin,"z")
					end
				end
			end
		end
	end
	end
	end
end

--modify the map with the collected data
local function destroy_portal_modify_map(destroy_n_copy)
	local destroy_sorted_table = {}
	for x,datax in pairs(destroy_n_copy) do
		for y,datay in pairs(datax) do
			for z,index in pairs(datay) do
				table.insert(destroy_sorted_table, vector.new(x,y,z))
			end
		end
	end
	minetest.bulk_set_node(destroy_sorted_table, {name="air"})
end

minetest.register_globalstep(function(dtime)
	--if indexes exist then calculate redstone
	if n_index and next(n_index) and portal_failure == false then
		--create the old version to help with deactivation calculation
		local n_copy = table.copy(n_index)
		portal_modify_map(n_copy)
		portal_failure = false
	end
	if x_failed == true then
		x_failed = false
	end
	if portal_failure == true then
		portal_failure = false
	end
	--clear the index to avoid cpu looping wasting processing power
	n_index = {}
	
	
	--if indexes exist then calculate redstone
	if destroy_n_index and next(destroy_n_index) and destroy_portal_failure == false then
		--create the old version to help with deactivation calculation
		local destroy_n_copy = table.copy(destroy_n_index)
		destroy_portal_modify_map(destroy_n_copy)
	end
	--clear the index to avoid cpu looping wasting processing power
	destroy_n_index = {}
end)
