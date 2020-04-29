--this is where mobs are defined

--this is going to be used to set an active mob limit
global_mob_table = {}


local path = minetest.get_modpath(minetest.get_current_modname())

--dofile(path.."/spawning.lua")
dofile(path.."/api.lua")
--dofile(path.."/items.lua")
--dofile(path.."/chatcommands.lua")
--these are called 'mob'init.lua so when modifying their code they do
--not get confused with each other
--dofile(path.."/pig/piginit.lua")
--dofile(path.."/slime/slimeinit.lua")
--dofile(path.."/flying_pig/flying_piginit.lua")
--dofile(path.."/exploder/exploderinit.lua")


