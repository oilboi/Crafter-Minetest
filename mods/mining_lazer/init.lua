minetest.register_craftitem("mining_lazer:mining_lazer", {
	description = "Mining Lazer",
	inventory_image = "mining_lazer.png",
	stack_max = 1,
	range = 0,
})

minetest.register_globalstep(function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		--don't magnetize to dead players
		if player:get_hp() > 0 then
			if player:get_wielded_item():get_name() == "mining_lazer:mining_lazer" then
				if player:get_player_control().RMB then
					local pos = player:getpos()
					pos.y = pos.y + 1.625
					local dir = player:get_look_dir()
					local pos2 = vector.add(pos,vector.multiply(dir,50))
					local ray = minetest.raycast(pos, pos2, false, false)
					
					if ray then
						--local pointed_thing = ray:next()
						for pointed_thing in ray do
							if pointed_thing then
								minetest.add_item(pointed_thing.under,minetest.get_node(pointed_thing.under).name)
								minetest.remove_node(pointed_thing.under)
								minetest.punch_node(pointed_thing.under)
							end
						end
					end
				end
			end
		end
	end
end)
