local credits_text = 
"this is a test"


play_game_credits = function(player)
	print("play credits to "..player:get_player_name())
	
	local meta = player:get_meta()
	
	if meta:get_int("roll credits") ~= 1 then
		
		local pos = player:get_pos()
		local pre_credits_pos = table.copy(pos)
		pos.y = 50000
		player:set_pos(pos)
		player:set_physics_override({speed = 0, jump = 0, sneak = false, gravity = 0})
		
		local credits_song = minetest.sound_play("credits", {to_player = player:get_player_name(),loop = true})
		
		local hud_bg = player:hud_add({
			hud_elem_type = "image",
			position = {x = 0.5, y = 0.5},
			scale = {
			x = -100,
			y = -100
			},
			text = "credits_bg.png"
		})
		
		local hud_text = player:hud_add({
			hud_elem_type = "image",
			position = {x = 0.5, y = 0},
			scale = {
			x = -100,
			y = -2000
			},
			--pixels
			offset = {
			x=0, 
			y=0
			},
			text = "credits_text.png"
		})
		
		meta:set_int("roll credits", 1)
		meta:set_int("credits hud bg", hud_bg)
		meta:set_int("credits hud text", hud_text)
		meta:set_int("credits song", credits_song)
		
		meta:set_int("credits scroll", 7900)
		
		meta:set_string("pre credits pos", minetest.pos_to_string(pre_credits_pos))
	end
end




--credits screen handling
minetest.register_globalstep(function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		local meta = player:get_meta()
		--check if the credits are playing
		if meta:get_int("roll credits") == 1 then
			--keep closing the formspec
			minetest.close_formspec(player:get_player_name(), "")
			
			
			local scroll = meta:get_int("credits scroll")
			local hud_text = meta:get_int("credits hud text")
			
			
			player:hud_remove(hud_text)
			
			if scroll > -6000 then
				scroll = math.ceil(scroll - (dtime*50)*2)
			end
			
			--print(scroll)
			local hud_text = player:hud_add({
					hud_elem_type = "image",
					position = {x = 0.75, y = 0},
					scale = {
					x = -100,
					y = -1350
					},
					--pixels
					
					offset = {
					x=0, 
					y= scroll
					},
					
					text = "credits_text.png",
					z_index = 500000,
				})
			meta:set_int("credits hud text", hud_text)
			meta:set_int("credits scroll", scroll)
			
			--skip the credits if spacebar is pressed
			local skip = player:get_player_control().jump
			if skip == true then
				local hud = meta:get_int("credits hud bg")
				local credits_song = meta:get_int("credits song")
				local pos = minetest.string_to_pos(meta:get_string("pre credits pos"))
				
				
				player:set_pos(pos)
				
				player:hud_remove(hud)
				minetest.after(0,function(player,hud_text)
					player:hud_remove(hud_text)
				end,player,hud_text)
				
				minetest.sound_stop(credits_song)
				
			
				meta:set_int("roll credits", 0)
				meta:set_int("credits hud bg", 0)
				meta:set_int("credits hud text", 0)
				
				meta:set_int("credits song", 0)
				meta:set_string("pre credits pos", "")
			end
		end
	end
end)


--exception for leaving game during the credits
minetest.register_on_joinplayer(function(player)
	local meta = player:get_meta()
	--check if the credits are playing
	if meta:get_int("roll credits") == 1 then
		local skip = player:get_player_control().jump

		local hud = meta:get_int("credits hud bg")
		local hud_text = meta:get_int("credits hud text")
		local credits_song = meta:get_int("credits song")
		local pos = minetest.string_to_pos(meta:get_string("pre credits pos"))
		
		
		player:set_pos(pos)
		player:hud_remove(hud)
		player:hud_remove(hud_text)
		minetest.sound_stop(credits_song)
		
	
		meta:set_int("roll credits", 0)
		meta:set_int("credits hud bg", 0)
		meta:set_int("credits song", 0)
		meta:set_string("pre credits pos", "")
	end
end)
