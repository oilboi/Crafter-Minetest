local minetest,math,vector,ipairs,tonumber = minetest,math,vector,ipairs,tonumber

local movement_class              = {} -- controls all data of the movement
local player_movement_data        = {} -- used to calculate player movement
local player_state_channels       = {} -- holds every player's channel
movement_pointer                  = {} -- allows other mods to index local data
movement_class.input_data         = nil
movement_class.hunger             = nil
movement_class.data               = nil
movement_class.data_list          = nil
movement_class.count              = nil
movement_class.name               = nil
movement_class.env_data           = nil
movement_class.channel_decyphered = nil
movement_class.in_water           = nil
movement_class.get_group          = minetest.get_item_group
movement_class.get_connected      = minetest.get_connected_players
movement_class.ipairs             = ipairs
movement_class.get_by_name        = minetest.get_player_by_name

-- creates volitile data for the game to use
movement_class.create_movement_variables = function(player)
	movement_class.name = player:get_player_name()
	if not player_movement_data[movement_class.name] then
		player_movement_data[movement_class.name] = {
			state        = 0    ,
			old_state    = 0    ,
			was_in_water = false,
			swimming     = false,
		}
	end
end

-- sets data for the game to use
movement_class.set_data = function(player,data)
	movement_class.name = player:get_player_name()
	if player_movement_data[movement_class.name] then
		for index,i_data in pairs(data) do
			if player_movement_data[movement_class.name][index] ~= nil then
				player_movement_data[movement_class.name][index] = i_data
			end
		end
	else
		movement_class.create_movement_variables(player)
	end
end

-- retrieves data for the game to use
movement_class.get_data = function(player)
	movement_class.name = player:get_player_name()
	if player_movement_data[movement_class.name] then
		return({
			state        = player_movement_data[movement_class.name].state       ,
			old_state    = player_movement_data[movement_class.name].old_state   ,
			was_in_water = player_movement_data[movement_class.name].was_in_water,
			swimming     = player_movement_data[movement_class.name].swimming    ,
		})
	end
end

-- removes movement data
movement_class.terminate = function(player)
	movement_class.name = player:get_player_name()
	if player_movement_data[movement_class.name] then
		player_movement_data[movement_class.name] = nil
	end
end

-- creates specific channels for players
minetest.register_on_joinplayer(function(player)
	movement_class.name = player:get_player_name()
	player_state_channels[movement_class.name] = minetest.mod_channel_join(movement_class.name..":player_movement_state")
	player:set_physics_override({
			jump   = 1.25,
			gravity= 1.25
	})
	movement_class.create_movement_variables(player)
end)

-- resets the player's state on death
minetest.register_on_respawnplayer(function(player)
	movement_class.set_data(player,{
		state        = 0    ,
		was_in_water = false,
	})
	movement_class.send_running_cancellation(player,false)
end)


-- delete data on player leaving
minetest.register_on_leaveplayer(function(player)
	movement_class.terminate(player)
end)

-- tells the client to stop sending running/bunnyhop data
movement_class.send_running_cancellation = function(player,sneaking)
	movement_class.name = player:get_player_name()
	player_state_channels[movement_class.name]:send_all(
		minetest.serialize({
			stop_running=true,
			state=sneaking
		}
	))
end

-- intercept incoming data messages
minetest.register_on_modchannel_message(function(channel_name, sender, message)
	movement_class.channel_decyphered = channel_name:gsub(sender,"")
	if sender ~= "" and movement_class.channel_decyphered == ":player_movement_state" then
		movement_class.data = tonumber(message)
		if type(movement_class.data) == "number" then
			movement_class.set_data(movement_class.get_by_name(sender),{
				state = movement_class.data
			})
		end
	end
end)

-- allows other mods to set data for the game to use
movement_pointer.set_data = function(player,data)
	movement_class.name = player:get_player_name()
	if player_movement_data[movement_class.name] then
		for index,i_data in pairs(data) do
			if player_movement_data[movement_class.name][index] ~= nil then
				player_movement_data[movement_class.name][index] = i_data
			end
		end
	else
		movement_class.create_movement_variables(player)
	end
end

-- allows other mods to retrieve data for the game to use
movement_pointer.get_data = function(player,requested_data)
	movement_class.name = player:get_player_name()
	if player_movement_data[movement_class.name] then
		movement_class.data_list = {}
		movement_class.count     = 0
		for index,i_data in pairs(requested_data) do
			if player_movement_data[movement_class.name][i_data] ~= nil then
				movement_class.data_list[i_data] = player_movement_data[movement_class.name][i_data]
				movement_class.count = movement_class.count + 1
			end
		end
		if movement_class.count > 0 then
			return(movement_class.data_list)
		else
			return(nil)
		end
	end
	return(nil)
end


-- controls player states
movement_class.control_state = function(player)
	movement_class.hunger = hunger_pointer.get_data(player,{"hunger"}).hunger
	movement_class.data   = movement_class.get_data(player)
	-- water movement data
	movement_class.env_data = environment_pointer.get_data(player,{"legs","head"})
	movement_class.in_water = {at_all=false,head=false,legs=false}		
	if movement_class.env_data then
		movement_class.in_water.legs = movement_class.get_group(movement_class.env_data.legs,"water") > 0
		movement_class.in_water.head = movement_class.get_group(movement_class.env_data.head,"water") > 0
		if movement_class.in_water.legs or movement_class.in_water.head then
			movement_class.in_water.at_all = true
			movement_class.set_data(player,{swimming=true})
		else
			movement_class.set_data(player,{swimming=false})
		end
	end
	
	if (movement_class.in_water.at_all ~= movement_class.data.was_in_water) or 
	(movement_class.data.state ~= movement_class.data.old_state) or 
	((movement_class.data.state == 1 or movement_class.data.state == 2) and movement_class.hunger and movement_class.hunger <= 6) then


		if not movement_class.in_water.at_all and movement_class.data.was_in_water then
			player:set_physics_override({
				sneak   = true,
			})
			player_pointer.force_update(player)
			player:set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})
			player_pointer.set_data(player,{
				collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
			})
		elseif movement_class.in_water.at_all and not movement_class.data.was_in_water then
			player:set_physics_override({
				sneak   = false,
			})

			player_pointer.force_update(player)
			player:set_eye_offset({x=0,y=-6,z=0},{x=0,y=-6,z=5.9})
			player_pointer.set_data(player,{
				collisionbox = {-0.3, 0.5, -0.3, 0.3, 1.2, 0.3},
			})
		end

		-- running/swimming fov modifier
		if movement_class.hunger and movement_class.hunger > 6 and (movement_class.data.state == 1 or movement_class.data.state == 2) then
			player:set_fov(1.25, true, 0.15)
			if movement_class.data.state == 2 then
				player:set_physics_override({speed=1.75})
			elseif movement_class.data.state == 1 then
				player:set_physics_override({speed=1.5})
			end
		elseif (not movement_class.in_water.at_all and movement_class.data.state ~= 1 and movement_class.data.state ~= 2 and 
		(movement_class.data.old_state == 1 or movement_class.data.old_state == 2)) or 
		(movement_class.in_water.at_all and movement_class.data.state ~= 1 and movement_class.data.state ~= 2 and movement_class.data.state ~= 3 and 
		(movement_class.data.old_state == 1 or movement_class.data.old_state == 2 or movement_class.data.old_state == 3))then

			player:set_fov(1, true,0.15)
			player:set_physics_override({speed=1})

			movement_class.send_running_cancellation(player,movement_class.data.state==3) --preserve network data
			
		elseif (movement_class.data.state == 1 or movement_class.data.state == 2) and (movement_class.hunger and movement_class.hunger <= 6) then
			player:set_fov(1, true,0.15)
			player:set_physics_override({speed=1})				
			movement_class.send_running_cancellation(player,false) --preserve network data
		end

		--sneaking
		if movement_class.data.state == 3 and movement_class.in_water.at_all then
			movement_class.send_running_cancellation(player,false)
		elseif not movement_class.in_water.at_all and movement_class.data.state == 3 and movement_class.data.old_state ~= 3 then
			player:set_eye_offset({x=0,y=-1,z=0},{x=0,y=-1,z=0})
		elseif not movement_class.in_water.at_all and movement_class.data.old_state == 3 and movement_class.data.state ~= 3 then
			player:set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})
		end

		movement_class.set_data(player,{
			old_state    = movement_class.data.state,
			was_in_water = movement_class.in_water.at_all
		})
	
	-- water movement
	elseif movement_class.in_water.at_all then
		if not movement_class.data.was_in_water then
			player:set_physics_override({
				sneak   = false ,
			})
			player:set_velocity(vector.new(0,0,0))
		end

		movement_class.set_data(player,{
			old_state    = movement_class.data.state,
			was_in_water = movement_class.in_water.at_all
		})
	end
end

minetest.register_globalstep(function(dtime)
	for _,player in movement_class.ipairs(movement_class.get_connected()) do
		movement_class.control_state(player)
	end
end)