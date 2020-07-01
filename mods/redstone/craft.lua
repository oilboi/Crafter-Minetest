local minetest = minetest
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
	output = "redstone:lever_off",
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
	output = "redstone:player_detector_0",
	recipe = {
		{"main:stone","main:stone","main:stone"},
		{"main:stone","redstone:torch","main:stone"},
		{"main:stone","main:stone","main:stone"},
	}
})
minetest.register_craft({
	output = "redstone:inverter_off",
	recipe = {
		{"redstone:dust","redstone:torch","redstone:dust"},
		{"main:stone","main:stone","main:stone"},
	}
})
minetest.register_craft({
	output = "redstone:comparator_0",
	recipe = {
		{"","redstone:torch",""},
		{"redstone:torch","redstone:dust","redstone:torch"},
		{"main:stone","main:stone","main:stone"},
	}
})

minetest.register_craft({
	output = "redstone:piston_off",
	recipe = {
		{"main:wood","main:wood","main:wood"},
		{"main:stone","main:iron","main:stone"},
		{"main:stone","redstone:dust","main:stone"},
	}
})

minetest.register_craft({
	output = "redstone:breaker_off",
	recipe = {
		{"main:stone","main:stone","main:stone"},
		{"main:stone","main:diamondpick","main:stone"},
		{"main:stone","main:stone","main:stone"},
	}
})

minetest.register_craft({
	output = "redstone:sticky_piston_off",
	type = "shapeless",
	recipe = {"mob:slimeball","redstone:piston_off"},
})

minetest.register_craft({
	output = "redstone:pressure_plate_0",
	recipe = {
		{"main:stone","main:stone"},
	}
})
