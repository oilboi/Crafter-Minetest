local minetest,vector,hud_manager = minetest,vector,hud_manager

local mod_storage        = minetest.get_mod_storage()

local drowning_class     = {}

drowning_class.get_group = minetest.get_item_group

local player_drowning    = {}

drowning_class.tick      = nil

drowning_class.breath    = nil

drowning_pointer         = {} -- allows other mods to access data

-- creates volitile data for the game to use
drowning_class.set_data = function(player,data)
	local name = player:get_player_name()
	if not player_drowning[name] then
		player_drowning[name] = {}
	end

	for index,i_data in pairs(data) do
		player_drowning[name][index] = i_data
	end

	if data.breath then

		if data.breath > 20 then
			if hud_manager.hud_exists(player,"breath_bg") then
				hud_manager.remove_hud(player,"breath_bg")
			end
			if hud_manager.hud_exists(player,"breath") then
				hud_manager.remove_hud(player,"breath")
			end
		else
			if not hud_manager.hud_exists(player,"breath_bg") then
				hud_manager.add_hud(player,"breath_bg",{
					hud_elem_type = "statbar",
					position = {x = 0.5, y = 1},
					text = "bubble_bg.png",
					number = 20,
					direction = 1,
					size = {x = 24, y = 24},
					offset = {x = 24*10, y= -(48 + 52 + 39)},
				})
			end
			if not hud_manager.hud_exists(player,"breath") then
				hud_manager.add_hud(player,"breath",{
					hud_elem_type = "statbar",
					position = {x = 0.5, y = 1},
					text = "bubble.png",
					number = data.breath,
					direction = 1,
					size = {x = 24, y = 24},
					offset = {x = 24*10, y= -(48 + 52 + 39)},
				})
			end

			hud_manager.change_hud({
				player    =  player ,
				hud_name  = "breath",
				element   = "number",
				data      =  data.breath
			})
		end
	end
end

-- indexes drowning data and returns it
drowning_class.get_data = function(player,requested_data)
	local name = player:get_player_name()
	if player_drowning[name] then
		local data_list = {}
		local count     = 0
		for index,i_data in pairs(requested_data) do
			if player_drowning[name][i_data] then
				data_list[i_data] = player_drowning[name][i_data]
				count = count + 1
			end
		end
		if count > 0 then
			return(data_list)
		else
			return(nil)
		end
	end
	return(nil)
end

-- removes data
drowning_class.terminate = function(player)
	local name = player:get_player_name()
	if player_drowning[name] then
		player_drowning[name] = nil
	end
end

-- loads data from mod storage
drowning_class.load_data = function(player)
	local name = player:get_player_name()
	if mod_storage:get_int(name.."d_save") > 0 then
		return({
				breath        = mod_storage:get_float(name.."breath"       ),
				breath_ticker = mod_storage:get_float(name.."breath_ticker"),
				drowning      = mod_storage:get_float(name.."drowning"     ),
			  })
	else
		return({
				breath        = 20,
				breath_ticker = 0 ,
				drowning      = 0 ,
			  })
	end
end

-- saves data to be utilized on next login
drowning_class.save_data = function(player)
	local name
	if type(player) ~= "string" and player:is_player() then
		name = player:get_player_name()
	elseif type(player) == "string" then
		name = player
	end
	if player_drowning[name] then
		for index,integer in pairs(player_drowning[name]) do
			mod_storage:set_float(name..index,integer)
		end
	end

	mod_storage:set_int(name.."d_save", 1)

	player_drowning[name] = nil
end

-- is used for shutdowns to save all data
drowning_class.save_all = function()
	for name,data in pairs(player_drowning) do
		drowning_class.save_data(name)
	end
end


-- creates volitile data for the game to use
drowning_pointer.set_data = function(player,data)
	local name = player:get_player_name()
	if not player_drowning[name] then
		player_drowning[name] = {}
	end

	for index,i_data in pairs(data) do
		player_drowning[name][index] = i_data
	end

	if data.breath then
		hud_manager.change_hud({
			player    =  player ,
			hud_name  = "breath",
			element   = "number",
			data      =  data.breath
		})
	end
end

-- indexes drowning data and returns it
drowning_pointer.get_data = function(player,requested_data)
	local name = player:get_player_name()
	if player_drowning[name] then
		local data_list = {}
		local count     = 0
		for index,i_data in pairs(requested_data) do
			if player_drowning[name][i_data] then
				data_list[i_data] = player_drowning[name][i_data]
				count = count + 1
			end
		end
		if count > 0 then
			return(data_list)
		else
			return(nil)
		end
	end
	return(nil)
end


-- remove stock health bar
minetest.hud_replace_builtin("breath",{
	hud_elem_type = "statbar",
	position = {x = 0, y = 0},
	text = "nothing.png",
	number = 0,
	direction = 0,
	size = {x = 0, y = 0},
	offset = {x = 0, y= 0},
})

minetest.register_on_joinplayer(function(player)
	local data = drowning_class.load_data(player)
	drowning_class.set_data(player,data)

	player:hud_set_flags({breathbar=false})
end)

-- saves specific users data for when they relog
minetest.register_on_leaveplayer(function(player)
	drowning_class.save_data(player)
	drowning_class.terminate(player)
end)

-- save all data to mod storage on shutdown
minetest.register_on_shutdown(function()
	drowning_class.save_all()
end)

-- reset the player's data
minetest.register_on_respawnplayer(function(player)
	drowning_class.set_data(player,{
		breath        = 20,
		breath_ticker = 0 ,
		drowning      = 0 ,
	})
end)

--handle the breath bar
drowning_class.handle_breath = function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		player:set_breath(50000)
		local name = player:get_player_name()

		local data = environment_pointer.get_data(player,{"head"})
		
		if data then
			data = data.head
		end

		if drowning_class.get_group(data, "drowning") > 0 then
			
			drowning_class.ticker = drowning_class.get_data(player,{"breath_ticker"})

			drowning_class.breath = drowning_class.get_data(player,{"breath"})
				
			if drowning_class.breath then
				drowning_class.breath = drowning_class.breath.breath
			end

			if drowning_class.ticker then
				drowning_class.ticker = drowning_class.ticker.breath_ticker
			end

			drowning_class.ticker = drowning_class.ticker + dtime
			
			if drowning_class.breath > 0 and drowning_class.ticker >= 1.3 then

				drowning_class.breath = drowning_class.breath - 2

				drowning_class.set_data(player,{breath = drowning_class.breath})
				
				drowning_class.set_data(player,{drowning = 0})

			elseif drowning_class.breath <= 0 and drowning_class.ticker >= 1.3 then
									
				drowning_class.set_data(player,{drowning=1})

				local hp =  player:get_hp()

				if hp > 0 then
					player:set_hp(hp-2)
					player:add_player_velocity(vector.new(0,-15,0))
				end
			end

			if drowning_class.ticker >= 1.3 then
				drowning_class.ticker = 0
			end

			drowning_class.set_data(player,{breath_ticker = drowning_class.ticker})
			
		else

			drowning_class.breath = drowning_class.get_data(player,{"breath"})
			
			drowning_class.ticker = drowning_class.get_data(player,{"breath_ticker"})

			if drowning_class.ticker then
				drowning_class.ticker = drowning_class.ticker.breath_ticker
			end

			if drowning_class.breath then
				drowning_class.breath = drowning_class.breath.breath
			end

			drowning_class.ticker = drowning_class.ticker + dtime		

			if drowning_class.breath < 21 and drowning_class.ticker >= 0.25 then
				
				drowning_class.breath = drowning_class.breath + 2
				
				drowning_class.set_data(player,{
					breath        = drowning_class.breath,
					drowning      = 0,
					breath_ticker = 0,
				})
			elseif drowning_class.breath < 21 then
				drowning_class.set_data(player,{breath_ticker = drowning_class.ticker})
			else
				drowning_class.set_data(player,{breath_ticker = 0})
			end
		end
	end
end

-- inject into main loop
minetest.register_globalstep(function(dtime)
	drowning_class.handle_breath(dtime)
end)