--this is where mobs are defined

--this is going to be used to set an active mob limit
global_mob_table = {}


local path = minetest.get_modpath(minetest.get_current_modname())

--dofile(path.."/spawning.lua")
dofile(path.."/api.lua")
dofile(path.."/items.lua")
dofile(path.."/chatcommands.lua")
