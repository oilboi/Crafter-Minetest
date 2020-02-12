--crafting recipes
local tool =     {"wood","stone", "iron","gold","diamond"}--the tool name
local material = {"wood","cobble","iron","gold","diamond"}--material to craft


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
