minetest.register_biome({
	name = "Nether",
	node_top = "air",
	depth_top = 0,
	node_filler = "air",
	depth_filler = 0,
	node_riverbed = "air",
	depth_riverbed= 0,
	node_stone = "air",
	node_water = "air",
	node_dungeon = "air",
	node_dungeon_alt = "air",
	node_dungeon_stair = "air",
	vertical_blend = 0,
	y_max = -10000,
	y_min = -20000,
	heat_point = -100,
	humidity_point = -100,
})

minetest.register_node("nether:bedrock", {
    description = "Bedrock",
    tiles = {"bedrock.png"},
    groups = {unbreakable = 1, pathable = 1},
    sounds = main.stoneSound(),
    is_ground_content = false,
    --light_source = 14, --debugging
})


minetest.register_node("nether:netherrack", {
    description = "Netherrack",
    tiles = {"netherrack.png"},
    groups = {stone = 1, pathable = 1},
    sounds = main.stoneSound(),
    is_ground_content = false,
    light_source = 7,
})


minetest.register_node("nether:obsidian", {
    description = "Obsidian",
    tiles = {"obsidian.png"},
    groups = {stone = 5, pathable = 1},
    --groups = {stone = 1, pathable = 1}, --leave this here for debug
    sounds = main.stoneSound(),
    is_ground_content = false,
    after_destruct = function(pos, oldnode)
		destroy_nether_portal(pos)
    end,
    --light_source = 7,
})

--this is from https://github.com/paramat/lvm_example/blob/master/init.lua
--hi paramat :D

-- Set the 3D noise parameters for the terrain.
local perlin= minetest.get_mapgen_params()
local np_terrain = {
	offset = 0,
	scale = 1,
	spread = {x = 384, y = 192, z = 384},
	seed = 5900033, --perlin.seed
	octaves = 5,
	persist = 0.63,
	lacunarity = 2.0,
	--flags = ""
}


-- Set singlenode mapgen (air nodes only).
-- Disable the engine lighting calculation since that will be done for a
-- mapchunk of air nodes and will be incorrect after we place nodes.

--minetest.set_mapgen_params({mgname = "singlenode", flags = "nolight"})


-- Get the content IDs for the nodes used.

local c_sandstone = minetest.get_content_id("nether:netherrack")
local c_bedrock = minetest.get_content_id("nether:bedrock")
local c_air = minetest.get_content_id("air")
local c_lava = minetest.get_content_id("main:lava")


-- Initialize noise object to nil. It will be created once only during the
-- generation of the first mapchunk, to minimise memory use.

local nobj_terrain = nil


-- Localise noise buffer table outside the loop, to be re-used for all
-- mapchunks, therefore minimising memory use.

local nvals_terrain = {}


-- Localise data buffer table outside the loop, to be re-used for all
-- mapchunks, therefore minimising memory use.

local data = {}


-- On generated function.

-- 'minp' and 'maxp' are the minimum and maximum positions of the mapchunk that
-- define the 3D volume.
minetest.register_on_generated(function(minp, maxp, seed)
	--nether starts at -10033 y
	if maxp.y > -10033 then
		return
	end
	-- Start time of mapchunk generation.
	--local t0 = os.clock()
	
	-- Noise stuff.

	-- Side length of mapchunk.
	local sidelen = maxp.x - minp.x + 1
	-- Required dimensions of the 3D noise perlin map.
	local permapdims3d = {x = sidelen, y = sidelen, z = sidelen}
	-- Create the perlin map noise object once only, during the generation of
	-- the first mapchunk when 'nobj_terrain' is 'nil'.
	nobj_terrain = minetest.get_perlin_map(np_terrain, permapdims3d) --nobj_terrain or 
	-- Create a flat array of noise values from the perlin map, with the
	-- minimum point being 'minp'.
	-- Set the buffer parameter to use and reuse 'nvals_terrain' for this.
	nobj_terrain:get3dMap_flat(minp, nvals_terrain)

	-- Voxelmanip stuff.

	-- Load the voxelmanip with the result of engine mapgen. Since 'singlenode'
	-- mapgen is used this will be a mapchunk of air nodes.
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	-- 'area' is used later to get the voxelmanip indexes for positions.
	local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
	-- Get the content ID data from the voxelmanip in the form of a flat array.
	-- Set the buffer parameter to use and reuse 'data' for this.
	vm:get_data(data)

	-- Generation loop.

	-- Noise index for the flat array of noise values.
	local ni = 1
	-- Process the content IDs in 'data'.
	-- The most useful order is a ZYX loop because:
	-- 1. This matches the order of the 3D noise flat array.
	-- 2. This allows a simple +1 incrementing of the voxelmanip index along x
	-- rows.
	-- rows.
	for z = minp.z, maxp.z do
	for y = minp.y, maxp.y do
		-- Voxelmanip index for the flat array of content IDs.
		-- Initialise to first node in this x row.
		local vi = area:index(minp.x, y, z)
		for x = minp.x, maxp.x do
			-- Consider a 'solidness' value for each node,
			-- let's call it 'density', where
			-- density = density noise + density gradient.
			local density_noise = nvals_terrain[ni]
			-- Density gradient is a value that is 0 at water level (y = 1)
			-- and falls in value with increasing y. This is necessary to
			-- create a 'world surface' with only solid nodes deep underground
			-- and only air high above water level.
			-- Here '128' determines the typical maximum height of the terrain.
			local density_gradient = (1 - y) / 128
			
			--print(density_noise, density_gradient)
			-- Place solid nodes when 'density' > 0.
			--if density_noise + density_gradient > 0 then
			if density_noise > 0  and y ~= -10033 then
				data[vi] = c_sandstone
			-- Otherwise if at or below water level place water.
			elseif y == -10033 then
				data[vi] = c_bedrock
			--elseif y <= 1 then
			--	data[vi] = c_water
			elseif y > -15000 then
				data[vi] = c_air
			else
				data[vi] = c_lava
			end

			-- Increment noise index.
			ni = ni + 1
			-- Increment voxelmanip index along x row.
			-- The voxelmanip index increases by 1 when
			-- moving by 1 node in the +x direction.
			vi = vi + 1
		end
	end
	end

	-- After processing, write content ID data back to the voxelmanip.
	vm:set_data(data)
	-- Calculate lighting for what has been created.
	--vm:calc_lighting()
	
	vm:set_lighting({day=7,night=7}, minp, maxp)
	
	-- Write what has been created to the world.
	vm:write_to_map()
	-- Liquid nodes were placed so set them flowing.
	--vm:update_liquids()

	-- Print generation time of this mapchunk.
	--local chugent = math.ceil((os.clock() - t0) * 1000)
	--print ("[lvm_example] Mapchunk generation time " .. chugent .. " ms")
end)


minetest.register_node("nether:portal", {
	description = "Nether Portal",

	tiles = {
		{
			name = "nether_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5,
			},
		},
		{
			name = "nether_portal.png",
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
	--alpha = 192,
	node_box = {
	type = "connected",
		-- connect_top =
		-- connect_bottom =
		connect_front = {-1/16,  -1/2, -1/2,   1/16,  1/2, 0 },
		connect_left =  {-1/2,   -1/2, -1/16, 0,   1/2,  1/16},
		connect_back =  {-1/16,  -1/2,  0,   1/16,  1/2,  1/2 },
		connect_right = { 0,   -1/2, -1/16,  1/2,   1/2,  1/16},
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

--modify the map with the collected data
local function portal_modify_map(n_copy)
	local sorted_table = {}
	for x,datax in pairs(n_copy) do
		for y,datay in pairs(datax) do
			for z,index in pairs(datay) do
				table.insert(sorted_table, vector.new(x,y,z))
			end
		end
	end
	minetest.bulk_set_node(sorted_table, {name="nether:portal"})
end

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
