-- Loot from the `default` mod is registered here,
-- with the rest being registered in the respective mods

dungeon_loot.registered_loot = {
	-- various items
	{name = "main:stick", chance = 0.6, count = {3, 6}},
	{name = "main:flint", chance = 0.4, count = {1, 3}},

	-- farming / consumable
	{name = "main:apple", chance = 0.4, count = {1, 4}},
	{name = "farming:cactus", chance = 0.4, count = {1, 4}},

	-- minerals
	{name = "main:coal", chance = 0.9, count = {1, 12}},
	{name = "main:gold", chance = 0.5},
	{name = "main:lapis", chance = 0.4, count = {1, 6}},
	{name = "main:iron", chance = 0.4, count = {1, 6}},
	{name = "main:diamond", chance = 0.2, count = {2, 3}},
	{name = "main:emerald", chance = 0.1, count = {2, 3}},
	{name = "main:sapphire", chance = 0.05, count = {2, 3}},
	{name = "main:ruby", chance = 0.025, count = {2, 3}},

	-- tools
	{name = "main:diamondsword", chance = 0.6},
	{name = "main:diamondaxe", chance = 0.3},
	{name = "main:diamondpick", chance = 0.05},

	-- natural materials
	{name = "main:sand", chance = 0.8, count = {4, 32}, y = {-64, 32768}},
	{name = "main:mossy_cobble", chance = 0.8, count = {4, 32}},
	{name = "nether:obsidian", chance = 0.25, count = {1, 3}, y = {-32768, -256}},
	{name = "nether:glowstone", chance = 0.25, count = {1, 3}, y = {-32768, -256}},
	{name = "main:glass", chance = 0.15, y = {-32768, -256}},
}

function dungeon_loot.register(t)
	if t.name ~= nil then
		t = {t} -- single entry
	end
	for _, loot in ipairs(t) do
		table.insert(dungeon_loot.registered_loot, loot)
	end
end

function dungeon_loot._internal_get_loot(pos_y)--, dungeontype)
	-- filter by y pos and type
	local ret = {}
	for _, l in ipairs(dungeon_loot.registered_loot) do
		--if l.y == nil or (pos_y >= l.y[1] and pos_y <= l.y[2]) then
			--if l.types == nil or table.indexof(l.types, dungeontype) ~= -1 then
		table.insert(ret, l)
			--end
		--end
	end
	return ret
end
