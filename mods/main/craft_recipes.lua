--crafting recipes

--cooking
minetest.register_craft({
	type = "cooking",
	output = "main:diamond",
	recipe = "main:diamondore",
	cooktime = 12,
})
minetest.register_craft({
	type = "cooking",
	output = "main:coal 4",
	recipe = "main:coalore",
	cooktime = 3,
})
minetest.register_craft({
	type = "cooking",
	output = "main:charcoal",
	recipe = "main:tree",
	cooktime = 2,
})
minetest.register_craft({
	type = "cooking",
	output = "main:gold",
	recipe = "main:goldore",
	cooktime = 9,
})
minetest.register_craft({
	type = "cooking",
	output = "main:iron",
	recipe = "main:ironore",
	cooktime = 6,
})
minetest.register_craft({
	type = "cooking",
	output = "main:stone",
	recipe = "main:cobble",
	cooktime = 3,
})

--fuel fuel fuel
minetest.register_craft({
	type = "fuel",
	recipe = "main:stick",
	burntime = 1,
})
minetest.register_craft({
	type = "fuel",
	recipe = "main:tree",
	burntime = 24,
})
minetest.register_craft({
	type = "fuel",
	recipe = "main:wood",
	burntime = 12,
})
minetest.register_craft({
	type = "fuel",
	recipe = "main:leaves",
	burntime = 3,
})
minetest.register_craft({
	type = "fuel",
	recipe = "main:coal",
	burntime = 20,
})
---crafting
minetest.register_craft({
	type = "shapeless",
	output = "main:wood 4",
	recipe = {"main:tree"},
})

minetest.register_craft({
	output = "main:stick 4",
	recipe = {
		{"main:wood"},
		{"main:wood"}
	}
})

local tool =     {"wood","stone", "iron","gold","diamond"}--the tool name
local material = {"wood","cobble","iron","gold","diamond"}--material to craft

for id,tool in pairs(tool) do
	minetest.register_craft({
		output = "main:"..tool.."pick",
		recipe = {
			{"main:"..material[id], "main:"..material[id], "main:"..material[id]},
			{"", "main:stick", ""},
			{"", "main:stick", ""}
		}
	})
	
	minetest.register_craft({
		output = "main:"..tool.."shovel",
		recipe = {
			{"","main:"..material[id], ""},
			{"", "main:stick", ""},
			{"", "main:stick", ""}
		}
	})
	
	minetest.register_craft({
		output = "main:"..tool.."axe",
		recipe = {
			{"main:"..material[id], "main:"..material[id], ""},
			{"main:"..material[id], "main:stick", ""},
			{"", "main:stick", ""}
		}
	})
	minetest.register_craft({
		output = "main:"..tool.."axe",
		recipe = {
			{"", "main:"..material[id], "main:"..material[id]},
			{"", "main:stick", "main:"..material[id]},
			{"", "main:stick", ""}
		}
	})
	
	minetest.register_craft({
		output = "main:"..tool.."sword",
		recipe = {
			{"","main:"..material[id], ""},
			{"","main:"..material[id], ""},
			{"", "main:stick", ""}
		}
	})
end
