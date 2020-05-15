minetest.register_chatcommand("spawn", {
	params = "<mob>",
	description = "Spawn x amount of a mob, used as /spawn 'mob' 10 or /spawn 'mob' for one",
	privs = {server = true},
	func = function( name, mob)
		--local vars
		local str = mob
		local amount = 1
		
		--checks if a player put a number of mobs
		local number_of_mobs = string.find(str, "%s%d+")
		
		
		--remove spaces from the string
		if number_of_mobs == nil then
			str:gsub("%s", "")
			str = "mob:"..mob
			--don't change amount
		else--or find values
			amount = tonumber(str:match("^.-%s(.*)"))
			str = "mob:"..str:match("(.*)%s")
		end
		--explain formatting
		if amount == nil or str == nil then
			minetest.chat_send_player(name, "Format as /spawn 'mob' 20  ...  or /spawn 'mob'")
		end
		
		--add amount of entities if registered
		if minetest.registered_entities[str] ~= nil then
			local pos = minetest.get_player_by_name(name):get_pos()
			pos.y = pos.y + 1
			--add in amount through loop
			if amount > 1 then
				for i = 1,amount do 
					minetest.add_entity(pos,str)
				end
			else --add single
				minetest.add_entity(pos,str)
			end
		else --tell player the mob doesn't exist if not a registered entity
			minetest.chat_send_player(name, str:match("^.-:(.*)"):gsub("^%l", string.upper).." is not a mob.")
		end
		
	end,
})

minetest.register_chatcommand("lookspawn", {
	params = "<mob>",
	description = "Spawn x amount of a mob, used as /spawn 'mob' 10 or /spawn 'mob' for one",
	privs = {server = true},
	func = function( name, mob)
		--local vars
		local str = mob
		local amount = 1
		
		--checks if a player put a number of mobs
		local number_of_mobs = string.find(str, "%s%d+")
		
		
		--remove spaces from the string
		if number_of_mobs == nil then
			str:gsub("%s", "")
			str = "mob:"..mob
			--don't change amount
		else--or find values
			amount = tonumber(str:match("^.-%s(.*)"))
			str = "mob:"..str:match("(.*)%s")
		end
		--explain formatting
		if amount == nil or str == nil then
			minetest.chat_send_player(name, "Format as /spawn 'mob' 20  ...  or /spawn 'mob'")
		end
		
		--add amount of entities if registered
		if minetest.registered_entities[str] ~= nil then
			local player = minetest.get_player_by_name(name)
			local pos = player:get_pos()
			pos.y = pos.y + 1.625
			local pos2 = vector.add(pos,vector.multiply(player:get_look_dir(),30))
			local ray = minetest.raycast(pos,pos2,false,false)
			local casted_pos = table.copy(pos)
			if ray then
				local intersection = ray:next()
				if intersection and intersection.above then
					casted_pos = intersection.above
				end
			end


			--add in amount through loop
			if amount > 1 then
				for i = 1,amount do 
					minetest.add_entity(casted_pos,str)
				end
			else --add single
				minetest.add_entity(casted_pos,str)
			end
		else --tell player the mob doesn't exist if not a registered entity
			minetest.chat_send_player(name, str:match("^.-:(.*)"):gsub("^%l", string.upper).." is not a mob.")
		end
		
	end,
})