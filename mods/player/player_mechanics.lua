local player_state_channel = minetest.mod_channel_join("player.player_movement_state")

minetest.register_on_modchannel_message(function(channel_name, sender, message)
	if channel_name == "player.player_movement_state" then
		local player = minetest.get_player_by_name(sender)
		local meta = player:get_meta()
		meta:set_string("player.player_movement_state", message)
	end
end)

minetest.register_on_joinplayer(function(player)
	player:set_physics_override({jump=1.25,gravity=1.25})
	local meta = player:get_meta()
	meta:set_string("player.player_movement_state", "0")
end)

minetest.register_globalstep(function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		local meta = player:get_meta()
		
		local running = (meta:get_string("player.player_movement_state") == "1")
		local bunny_hopping = (meta:get_string("player.player_movement_state") == "2")
		local sneaking = (meta:get_string("player.player_movement_state") == "3")
		
		--print(running, bunny_hopping)
		
		
		--running FOV modifier
		if running or bunny_hopping then
			if bunny_hopping == true then
                player:set_fov(1.4, true,0.1)
				player:set_physics_override({speed=1.75})
			else
                player:set_fov(1.2, true,0.1)
				player:set_physics_override({speed=1.5})
			end
		else
            player:set_fov(1, true,0.1)
			player:set_physics_override({speed=1})
			--meta:set_float("running_timer", 0)
		end
		
		--sneaking
		if sneaking then
            player:set_fov(0.8, true,0.1)
			player:set_eye_offset({x=0,y=-1,z=0},{x=0,y=-1,z=0})
		else
			player:set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})
		end
		
		--remember to implement hunger
		
		--eating
		if player:get_player_control().RMB then
		
			local item = player:get_wielded_item():get_name()
			local satiation = minetest.get_item_group(item, "satiation")
			local hunger = minetest.get_item_group(item, "hunger")
			
			
			if hunger and satiation then
				local meta = player:get_meta()
				if meta:get_int("hunger") == 20 and meta:get_int("satiation") == 20 then return end
				local eating = meta:get_float("eating")
				local eating_timer = meta:get_float("eating_timer")
				
				eating = eating + dtime
				eating_timer = eating_timer + dtime
				
				local ps = minetest.add_particlespawner({
					amount = 30,
					time = 0.00001,
					minpos = {x=-0.2, y=-1.5, z=0.5},
					maxpos = {x=0.2, y=1.7, z=0.5},
					minvel = vector.new(-0.5,0,-0.5),
					maxvel = vector.new(0.5,0,0.5),
					minacc = {x=0, y=-9.81, z=1},
					maxacc = {x=0, y=-9.81, z=1},
					minexptime = 0.5,
					maxexptime = 1.5,
					minsize = 0.5,
					maxsize = 1,
					attached = player,
					collisiondetection = true,
					collision_removal = true,
					vertical = false,
					texture = "eat_particles_1.png"
				})
				
				if eating_timer + dtime > 0.25 then
					minetest.sound_play("eat", {
						to_player = player:get_player_name(),
						gain = 1.0,  -- default
						pitch = math.random(60,100)/100,
					})
					eating_timer = 0
				end
				
				if eating + dtime >= 1 then
					local stack = player:get_wielded_item()
					stack:take_item(1)
					minetest.eat_food(player,item)
					eating = 0
					minetest.sound_play("eat_finish", {
						to_player = player:get_player_name(),
						gain = 0.2,  -- default
						pitch = math.random(60,85)/100,
					})
				end
				
				meta:set_float("eating_timer", eating_timer)
				meta:set_float("eating", eating)
			else
				local meta = player:get_meta()
				meta:set_float("eating", 0)
				meta:set_float("eating_timer", 0)
				
			end
		else
			local meta = player:get_meta()
			meta:set_float("eating", 0)
			meta:set_float("eating_timer", 0)
		end
		
	end
end)
