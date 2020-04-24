aetherportalSchematic = {
	size = {x = 4, y = 5, z = 3},
	data = {
		-- The side of the bush, with the air on top
		{name = "nether:glowstone"},{name = "nether:glowstone"},{name = "nether:glowstone"},{name = "nether:glowstone"},
		{name = "air"},{name = "air"},{name = "air"},{name = "air"},
		{name = "air"},{name = "air"},{name = "air"},{name = "air"},
		{name = "air"},{name = "air"},{name = "air"},{name = "air"},-- lower layer
		{name = "air"},{name = "air"},{name = "air"},{name = "air"}, -- top layer
		-- The center of the bush, with stem at the base and a pointy leave 2 nodes above
		{name = "nether:glowstone"},{name = "nether:glowstone"},{name = "nether:glowstone"},{name = "nether:glowstone"},
		{name = "nether:glowstone"},{name = "aether:portal"},{name = "aether:portal"},{name = "nether:glowstone"},
		{name = "nether:glowstone"},{name = "aether:portal"},{name = "aether:portal"},{name = "nether:glowstone"},
		{name = "nether:glowstone"},{name = "aether:portal"},{name = "aether:portal"},{name = "nether:glowstone"},-- lower layer
		{name = "nether:glowstone"},{name = "nether:glowstone"},{name = "nether:glowstone"},{name = "nether:glowstone"}, -- top layer
		-- The other side of the bush, same as first side
		{name = "nether:glowstone"},{name = "nether:glowstone"},{name = "nether:glowstone"},{name = "nether:glowstone"},
		{name = "air"},{name = "air"},{name = "air"},{name = "air"},
		{name = "air"},{name = "air"},{name = "air"},{name = "air"},
		{name = "air"},{name = "air"},{name = "air"},{name = "air"},-- lower layer
		{name = "air"},{name = "air"},{name = "air"},{name = "air"}, -- top layer
		}
		}
minetest.register_chatcommand("aether", {
	params = "<mob>",
	description = "Spawn x amount of a mob, used as /spawn 'mob' 10 or /spawn 'mob' for one",
	privs = {server = true},
	func = function( name, mob)
		local player = minetest.get_player_by_name(name)
		local pos = player:get_pos()
		
		minetest.place_schematic(pos, aetherportalSchematic,"0",nil,true,"place_center_x, place_center_z")
	end,
})
