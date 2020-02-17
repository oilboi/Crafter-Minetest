--this is where mobs are defined
minetest.register_globalstep(function(dtime)
	--collection
	for _,player in ipairs(minetest.get_connected_players()) do
		--don't magnetize to dead players
		if player:get_hp() > 0 then
			local pos = player:getpos()
			local inv = player:get_inventory()
			--radial detection
			for _,object in ipairs(minetest.get_objects_inside_radius({x=pos.x,y=pos.y+eye_height,z=pos.z}, 3)) do
				if not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "__builtin:item" then
					if inv and inv:room_for_item("main", ItemStack(object:get_luaentity().itemstring)) then
						if object:get_luaentity().collectable == true and object:get_luaentity().collected == false then
							minetest.sound_play("pickup", {
								to_player = player,
								gain = 0.4,
								pitch = math.random(60,100)/100
							})
							inv:add_item("main", ItemStack(object:get_luaentity().itemstring))
							object:moveto({x=pos.x,y=pos.y+eye_height,z=pos.z,continuous=true})
							object:get_luaentity().collected = true
						end
					end
				end
			end
		end
	end
end)
