--[[
depth = initial level found
]]--

	
local gold_depth = 64
local incriment = 50
local loops = 31000/incriment

for i = 1,loops do
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "main:coalore",
		wherein        = "main:stone",
		clust_scarcity = 13 * 13 * 13,
		clust_num_ores = 5,
		clust_size     = 3,
		y_max          = 31000,
		y_min          = -31000,
	})
end
