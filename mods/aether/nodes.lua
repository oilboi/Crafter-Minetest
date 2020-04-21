local tool = {"main:woodpick","main:stonepick","main:ironpick","main:goldpick","main:diamondpick"}

local path = minetest.get_modpath("nether")
dofile(path.."/schem.lua")

minetest.register_node("aether:stone", {
    description = "Aether Stone",
    tiles = {"stone.png^[colorize:aqua:40"},
    groups = {stone = 1, hand = 1,pathable = 1},
    sounds = main.stoneSound(),
    drop = {
		max_items = 1,
		items= {
			{
				rarity = 0,
				tools = tool,
				items = {"aether:cobble"},
			},
			},
		},
	})
	
	
minetest.register_node("aether:cobble", {
    description = "Aether Cobblestone",
    tiles = {"cobble.png^[colorize:aqua:40"},
    groups = {stone = 1, pathable = 1},
    sounds = main.stoneSound(),
    drop = {
		max_items = 1,
		items= {
			{
				rarity = 0,
				tools = tool,
				items = {"aether:cobble"},
			},
			},
		},
})


minetest.register_node("aether:dirt", {
    description = "Aether Dirt",
    tiles = {"dirt.png^[colorize:aqua:40"},
    groups = {dirt = 1, soil=1,pathable = 1, farm_tillable=1},
    sounds = main.dirtSound(),
    paramtype = "light",
})

minetest.register_node("aether:grass", {
    description = "Aether Grass",
    tiles = {"grass.png^[colorize:aqua:40"},
    groups = {grass = 1, soil=1,pathable = 1, farm_tillable=1},
    sounds = main.dirtSound(),
    drop="aether:dirt",
})
