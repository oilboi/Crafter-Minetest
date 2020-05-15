--The item collection magnet
--Item collection
minetest.register_globalstep(function(dtime)
	--collection
	for _,player in ipairs(minetest.get_connected_players()) do                    
		--don't magnetize to dead players
		if player:get_hp() > 0 then
            local meta = player:get_meta()
            local experience_collection_buffer = meta:get_float("experience_collection_buffer")
            if experience_collection_buffer > 0 then
                experience_collection_buffer = experience_collection_buffer - dtime
                if experience_collection_buffer < 0 then
                    experience_collection_buffer = 0
                end
            end
                            
            meta:set_float("experience_collection_buffer", experience_collection_buffer)
                            
			local pos = player:get_pos()
			local inv = player:get_inventory()
			--radial detection
			for _,object in ipairs(minetest.get_objects_inside_radius({x=pos.x,y=pos.y+0.5,z=pos.z}, 2)) do
				if not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "__builtin:item" then
					local pos2 = object:getpos()
					local diff = vector.subtract(pos2,pos).y
					if diff >= 0 and inv and inv:room_for_item("main", ItemStack(object:get_luaentity().itemstring)) then
						if object:get_luaentity().collectable == true and object:get_luaentity().collected == false then
							minetest.sound_play("pickup", {
								to_player = player:get_player_name(),
								gain = 0.4,
								pitch = math.random(60,100)/100
							})
							inv:add_item("main", ItemStack(object:get_luaentity().itemstring))
							object:get_luaentity().collector = player:get_player_name()
							object:get_luaentity().collected = true
							 -- print("Set flag at item: "..dump(object:getpos()))
							--object:moveto({x=pos.x,y=pos.y+eye_height,z=pos.z,continuous=true})
							
						end
					end
                elseif not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "experience:orb" then
                        object:get_luaentity().collector = player:get_player_name()
						object:get_luaentity().collected = true
				end
			end
		end
	end
end)
