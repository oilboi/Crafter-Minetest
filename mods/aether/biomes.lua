local 
minetest,math
=
minetest,math


minetest.register_biome({
	name = "aether",
	node_top = "air",
	depth_top = 1,
	node_filler = "air",
	depth_filler = 3,
	node_riverbed = "air",
	depth_riverbed= 0,
	node_stone = "air",
	node_water = "air",
	node_dungeon = "air",
	node_dungeon_alt = "air",
	node_dungeon_stair = "air",
	node_cave_liquid = "air",
	vertical_blend = 0,
	y_max = 31000,
	y_min = 21000,
	heat_point = -100,
	humidity_point = -100,
})

--this is from https://github.com/paramat/lvm_example/blob/master/init.lua
--hi paramat :D

-- Set the 3D noise parameters for the terrain.
local np_terrain = {
	offset = 0,
	scale = 1,
	spread = {x = 200, y = 100, z = 200},
	seed = tonumber(minetest.get_mapgen_setting("seed")) or math.random(0,999999999),
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

local c_dirt = minetest.get_content_id("aether:dirt")
local c_stone = minetest.get_content_id("aether:stone")
local c_air = minetest.get_content_id("air")
local c_grass = minetest.get_content_id("aether:grass")
-- Initialize noise object to nil. It will be created once only during the
-- generation of the first mapchunk, to minimise memory use.
local nobj_terrain = nil
-- Localise noise buffer table outside the loop, to be re-used for all
-- mapchunks, therefore minimising memory use.
local nvals_terrain = {}
-- Localise data buffer table outside the loop, to be re-used for all
-- mapchunks, therefore minimising memory use.

local data = {}
local n_pos = {}
local node2 = ""
local vi = {}
local content_id = minetest.get_name_from_content_id
local sidelen = {}
local permapdims3d = {}
local nobj_terrain = {}
local vm, emin, emax = {},{},{}
local area = {}
local ni = 1
local density_noise = {}
local get_map = minetest.get_perlin_map
local get_mapgen_object = minetest.get_mapgen_object
-- On generated function.

-- 'minp' and 'maxp' are the minimum and maximum positions of the mapchunk that
-- define the 3D volume.
minetest.register_on_generated(function(minp, maxp, seed)
	--aether starts at 21000
	if minp.y < 21000 then
		return
	end
	-- Start time of mapchunk generation.
	--local t0 = minetest.get_us_time()/1000000
	
	-- Noise stuff.
	sidelen = maxp.x - minp.x + 1

	permapdims3d = {x = sidelen, y = sidelen, z = sidelen}

	nobj_terrain = get_map(np_terrain, permapdims3d)

	nobj_terrain:get_3d_map_flat(minp, nvals_terrain)
	ni = 1

	vm, emin, emax = get_mapgen_object("voxelmanip")

	area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}

	vm:get_data(data)

	for z = minp.z, maxp.z do
	for y = minp.y, maxp.y do

		vi = area:index(minp.x, y, z)
		for x = minp.x, maxp.x do

			density_noise = nvals_terrain[ni]

			if density_noise > 0.1 then
				data[vi] = c_dirt
			else
				--force create grass
				n_pos = area:index(x,y-1,z)
				node2 = content_id(data[n_pos])
				if node2 == "aether:dirt" then
					data[n_pos] = c_grass
				end
			end

			ni = ni + 1

			vi = vi + 1
		end
	end
	end


	vm:set_data(data)

	vm:set_lighting({day=15,night=0}, minp, maxp)

	vm:write_to_map()
		
		
	-- Liquid nodes were placed so set them flowing.
	--vm:update_liquids()

	-- Print generation time of this mapchunk.
	--local chugent = math.ceil((minetest.get_us_time()/1000000- t0) * 1000)
	--print ("[lvm_example] Mapchunk generation time " .. chugent .. " ms")
end)
