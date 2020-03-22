--these are all the craft recipes
minetest.register_craft({
	output = "redstone:button_off",
	recipe = {
		{"main:stone"},
	}
})
minetest.register_craft({
	output = "redstone:torch",
	recipe = {
		{"redstone:dust"},
		{"main:stick"},
	}
})
minetest.register_craft({
	output = "redstone:switch_off",
	recipe = {
		{"main:stick"},
		{"main:stone"},
	}
})
minetest.register_craft({
	output = "redstone:repeater_off_0",
	recipe = {
		{"redstone:torch","redstone:dust","redstone:torch"},
		{"main:stone","main:stone","main:stone"},
	}
})
minetest.register_craft({
	output = "redstone:comparator",
	recipe = {
		{"","redstone:torch",""},
		{"redstone:torch","redstone:dust","redstone:torch"},
		{"main:stone","main:stone","main:stone"},
	}
})
minetest.register_craft({
	output = "redstone:light_off",
	type = "shapeless",
	recipe = {"main:glass","redstone:dust"},
})

minetest.register_craft({
	output = "redstone:piston_off",
	recipe = {
		{"main:wood","main:wood","main:wood"},
		{"main:stone","main:iron","main:stone"},
		{"main:stone","redstone:dust","main:stone"},
	}
})
