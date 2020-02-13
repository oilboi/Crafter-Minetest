print("Initialized Main")

main = {}

local path = minetest.get_modpath("main")

dofile(path.."/sounds.lua")
dofile(path.."/nodes.lua")
dofile(path.."/ore.lua")
dofile(path.."/items.lua")
dofile(path.."/schematics.lua")
dofile(path.."/mapgen.lua")
dofile(path.."/tools.lua")
dofile(path.."/settings.lua")
dofile(path.."/craft_recipes.lua")

