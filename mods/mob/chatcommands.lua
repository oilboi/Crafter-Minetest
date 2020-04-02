minetest.register_chatcommand("spawn", {
	params = "<mobname>",
	description = "Spawn a mob",
	privs = {give = true},
	func = function( name, mob)
		local input = mob
		local amount = 1
		local number_of_mobs = input.find(input, "%s%d+")
		if number_of_mobs == nil then
			input:gsub("%s", "")
			input = "mob:"..input
		end
		if minetest.registered_entities[input] ~= nil then
			local pos = minetest.get_player_by_name(name):getpos()
			pos.y = pos.y + 1.625
			minetest.add_entity(pos,input)
		end
	end,
})
