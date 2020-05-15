minetest.register_biome({
	name = "Nether",
	node_top = "air",
	depth_top = 0,
	node_filler = "air",
	depth_filler = 0,
	node_riverbed = "air",
	depth_riverbed= 0,
	node_cave_liquid = "air",
	node_stone = "air",
	node_water = nil,
	node_dungeon = "air",
	node_dungeon_alt = "air",
	node_dungeon_stair = "air",
	vertical_blend = 0,
	y_max = -10033,
	y_min = -20113,
	heat_point = -100,
	humidity_point = -100,
})

--[[
minetest.register_decoration({
	name = "Nether Eternal Fire",
	deco_type = "simple",
	place_on = {"nether:netherrack"},
	sidelen = 16,
	fill_ratio = 0.03,
	biomes = {"Nether"},
	y_max = -10033,
	y_min = -15000,
	decoration = "fire:fire",
	height = 1,
})
]]--

--this is from https://github.com/paramat/lvm_example/blob/master/init.lua
--hi paramat :D

-- Set the 3D noise parameters for the terrain.
local np_terrain = {
	offset = 0,
	scale = 1,
	spread = {x = 384, y = 192, z = 384},
	seed = tonumber(minetest.get_mapgen_setting("seed")) or math.random(0,999999999),
	octaves = 5,
	persist = 0.63,
	lacunarity = 2.0,
	--flags = ""
}

minetest.register_decoration({
	name = "nether:tree",
	deco_type = "schematic",
	place_on = {"nether:netherrack"},
	sidelen = 16,
	noise_params = {
		offset = 0.024,
		scale = 0.015,
		spread = {x = 250, y = 250, z = 250},
		seed = 2,
		octaves = 3,
		persist = 0.66
	},
	--biomes = {},
	y_max = -10000,
	y_min = -15000,
	schematic = nethertreeSchematic,
	flags = "place_center_x, place_center_z",
	rotation = "random",
	spawn_by = "air",
	num_spawn_by = 1,
})



-- Set singlenode mapgen (air nodes only).
-- Disable the engine lighting calculation since that will be done for a
-- mapchunk of air nodes and will be incorrect after we place nodes.

--minetest.set_mapgen_params({mgname = "singlenode", flags = "nolight"})


-- Get the content IDs for the nodes used.

local c_sandstone = minetest.get_content_id("nether:netherrack")
local c_bedrock = minetest.get_content_id("nether:bedrock")
local c_air = minetest.get_content_id("air")
local c_lava = minetest.get_content_id("nether:lava")


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



local sidelen
local permapdims3d
local vm
local emin
local emax
local area
local vi
local density_noise
local density_gradient
minetest.register_on_generated(function(minp, maxp, seed)
	--nether starts at -10033 y
	if maxp.y > -10033 or maxp.y < -20033 then
		return
	end
	-- Start time of mapchunk generation.
	--local t0 = os.clock()
	
	-- Noise stuff.

	-- Side length of mapchunk.
	sidelen = maxp.x - minp.x + 1
	-- Required dimensions of the 3D noise perlin map.
	permapdims3d = {x = sidelen, y = sidelen, z = sidelen}
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
	vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	-- 'area' is used later to get the voxelmanip indexes for positions.
	area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
	-- Get the content ID data from the voxelmanip in the form of a flat array.
	-- Set the buffer parameter to use and reuse 'data' for this.
	vm:get_data(data)

	-- Generation loop.

	-- Noise index for the flat array of noise values.
	
	-- Process the content IDs in 'data'.
	-- The most useful order is a ZYX loop because:
	-- 1. This matches the order of the 3D noise flat array.
	-- 2. This allows a simple +1 incrementing of the voxelmanip index along x
	-- rows.
	-- rows.
	
	local ni = 1
	for z = minp.z, maxp.z do
	for y = minp.y, maxp.y do
		-- Voxelmanip index for the flat array of content IDs.
		-- Initialise to first node in this x row.
		vi = area:index(minp.x, y, z)
		for x = minp.x, maxp.x do
			-- Consider a 'solidness' value for each node,
			-- let's call it 'density', where
			-- density = density noise + density gradient.
			density_noise = nvals_terrain[ni]
			-- Density gradient is a value that is 0 at water level (y = 1)
			-- and falls in value with increasing y. This is necessary to
			-- create a 'world surface' with only solid nodes deep underground
			-- and only air high above water level.
			-- Here '128' determines the typical maximum height of the terrain.
			density_gradient = (1 - y) / 128
			
			--print(density_noise, density_gradient)
			-- Place solid nodes when 'density' > 0.
			--if density_noise + density_gradient > 0 then
			if density_noise > 0  and y ~= -10033 and y ~= -20112 then
				data[vi] = c_sandstone
			-- create bedrock layer
			elseif y == -10033 or y == -20112 then
				data[vi] = c_bedrock
			--elseif y <= 1 then
			--	data[vi] = c_water
			--elseif y > -15000 then
				--data[vi] = c_air
			elseif y <= -15000 then
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
	minetest.generate_ores(vm)
	
	minetest.generate_decorations(vm)
	
	--minetest.generate_decorations(vm)
	vm:set_lighting({day=7,night=7}, minp, maxp)
	
	-- Write what has been created to the world.
	vm:write_to_map()
	-- Liquid nodes were placed so set them flowing.
	--vm:update_liquids()

	-- Print generation time of this mapchunk.
	--local chugent = math.ceil((os.clock() - t0) * 1000)
	--print ("[lvm_example] Mapchunk generation time " .. chugent .. " ms")
end)
