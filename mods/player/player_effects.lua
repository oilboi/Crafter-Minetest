--this is to check if the player is exploring a cave
--if exploring cave not near an open shaft then play a scary noise
--every 5-7 minutes
local scary_sound_player_timer = 0
minetest.register_globalstep(function(dtime)
	scary_sound_player_timer = scary_sound_player_timer + dtime
	--print(scary_sound_player_timer)
	--try to play every 5 minutes
	if scary_sound_player_timer > 300 then
		scary_sound_player_timer = math.random(-120,0)
		for _,player in ipairs(minetest.get_connected_players()) do
			local pos = player:get_pos()
			pos.y = pos.y + 1.625
			local light = minetest.get_node_light(pos)
			if pos.y < 0 and light <= 13 then
				--print(light)
				minetest.sound_play("scary_noise",{to_player = player:get_player_name(),gain=0.7,pitch=math.random(70,100)/100})
			end	
		end
	end
end)
