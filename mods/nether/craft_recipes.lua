minetest.register_craft({
	type = "cooking",
	output = "main:gold",
	recipe = "nether:goldore",
	cooktime = 5,
})
minetest.register_craft({
	type = "cooking",
	output = "main:iron",
	recipe = "nether:ironore",
	cooktime = 3,
})
minetest.register_craft({
	type = "shapeless",
	output = "nether:glowstone",
	recipe = {"nether:glowstone_dust","nether:glowstone_dust","nether:glowstone_dust","nether:glowstone_dust"},
})
