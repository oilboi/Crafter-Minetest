portalSchematic = {
	size = {x = 4, y = 5, z = 3},
	data = {
		-- The side of the bush, with the air on top
		{name = "nether:obsidian"},{name = "nether:obsidian"},{name = "nether:obsidian"},{name = "nether:obsidian"},
		{name = "air"},{name = "air"},{name = "air"},{name = "air"},
		{name = "air"},{name = "air"},{name = "air"},{name = "air"},
		{name = "air"},{name = "air"},{name = "air"},{name = "air"},-- lower layer
		{name = "air"},{name = "air"},{name = "air"},{name = "air"}, -- top layer
		-- The center of the bush, with stem at the base and a pointy leave 2 nodes above
		{name = "nether:obsidian"},{name = "nether:obsidian"},{name = "nether:obsidian"},{name = "nether:obsidian"},
		{name = "nether:obsidian"},{name = "nether:portal"},{name = "nether:portal"},{name = "nether:obsidian"},
		{name = "nether:obsidian"},{name = "nether:portal"},{name = "nether:portal"},{name = "nether:obsidian"},
		{name = "nether:obsidian"},{name = "nether:portal"},{name = "nether:portal"},{name = "nether:obsidian"},-- lower layer
		{name = "nether:obsidian"},{name = "nether:obsidian"},{name = "nether:obsidian"},{name = "nether:obsidian"}, -- top layer
		-- The other side of the bush, same as first side
		{name = "nether:obsidian"},{name = "nether:obsidian"},{name = "nether:obsidian"},{name = "nether:obsidian"},
		{name = "air"},{name = "air"},{name = "air"},{name = "air"},
		{name = "air"},{name = "air"},{name = "air"},{name = "air"},
		{name = "air"},{name = "air"},{name = "air"},{name = "air"},-- lower layer
		{name = "air"},{name = "air"},{name = "air"},{name = "air"}, -- top layer
		}
		}
minetest.register_chatcommand("nether", {
	params = "<mob>",
	description = "Spawn x amount of a mob, used as /spawn 'mob' 10 or /spawn 'mob' for one",
	privs = {server = true},
	func = function( name, mob)
		local player = minetest.get_player_by_name(name)
		local pos = player:get_pos()
		
		minetest.place_schematic(pos, portalSchematic,"0",nil,true,"place_center_x, place_center_z")
	end,
})

--[[
left - > right
bottom - > top
front -> back

]]--

nethertreeSchematic = {
	size = {x = 3, y = 6, z = 3},
	data = {
		-- The side of the bush, with the air on top
		{name = "air"},	   {name = "air"},	   {name = "air"},
		{name = "air"},	   {name = "air"},	   {name = "air"},
		{name = "air"},	   {name = "air"},	   {name = "air"},
		{name = "nether:leaves"}, {name = "nether:leaves"}, {name = "nether:leaves"}, -- lower layer
		{name = "nether:leaves"}, {name = "nether:leaves"}, {name = "nether:leaves"}, -- middle layer
		{name = "air"},	   {name = "air"},	   {name = "air"}, -- top layer
		-- The center of the bush, with stem at the base and a pointy leave 2 nodes above
		{name = "air"},	   {name = "nether:tree"},	{name = "air"},
		{name = "air"},	   {name = "nether:tree"},	{name = "air"},
		{name = "air"},	   {name = "nether:tree"},	{name = "air"},
		{name = "nether:leaves"}, {name = "nether:tree"},	{name = "nether:leaves"}, -- lower layer
		{name = "nether:leaves"}, {name = "nether:tree"},    {name = "nether:leaves"}, -- middle layer
		{name = "air"},	   {name = "nether:leaves"},    {name = "air"}, -- top layer
		-- The other side of the bush, same as first side
		{name = "air"},	   {name = "air"},	   {name = "air"},
		{name = "air"},	   {name = "air"},	   {name = "air"},
		{name = "air"},	   {name = "air"},	   {name = "air"},
		{name = "nether:leaves"}, {name = "nether:leaves"}, {name = "nether:leaves"}, -- lower layer
		{name = "nether:leaves"}, {name = "nether:leaves"}, {name = "nether:leaves"}, -- middle layer
		{name = "air"},	   {name = "air"},	   {name = "air"}, -- top layer
		}
		}
