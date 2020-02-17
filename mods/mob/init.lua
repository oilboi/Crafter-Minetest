--this is where mobs are defined
minetest.register_globalstep(function(dtime)
	--collection
	for _,player in ipairs(minetest.get_connected_players()) do
		--don't magnetize to dead players
		if player:get_hp() > 0 then
			local pos = player:getpos()
			--radial detection
			for _,object in ipairs(minetest.get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, 3)) do
				--[[
				get chunk player is in by dividing floored position by 16
				
				]]--

			end
		end
	end
end)
