local
minetest,ipairs,math
=
minetest,ipairs,math

--detects players and outputs accordingly
for i = 0,9  do

minetest.register_node("redstone:player_detector_"..i, {
	description = "Redstone Player Detector",
	drawtype = "normal",
	tiles = {"player_detector.png"},
	paramtype = "light",
	paramtype2 = "none",
	drop = "redstone:player_detector_0",
	groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4, torch=1,redstone=1,redstone_torch=1,redstone_power=i, redstone_player_detection = 1},
	legacy_wallmounted = true,
	
	on_construct = function(pos)
		redstone.inject(pos,{
            name = "redstone:player_detector_"..i,
            torch = i,
		})
		redstone.player_detector_add(pos)
		redstone.update(pos)
	end,
	on_destruct = function(pos, oldnode)
		redstone.player_detector_remove(pos)
		redstone.inject(pos,nil)
		redstone.update(pos)
	end,
	sounds = main.stoneSound(),
})

minetest.register_lbm({
    name = "redstone:player_detector_"..i,
    nodenames = {"redstone:player_detector_"..i},
    run_at_every_load = true,
    action = function(pos)
        redstone.inject(pos,{
            name = "redstone:player_detector_"..i,
            torch = i,
		})
		redstone.player_detector_add(pos)
    end,
})

end

--[[

minetest.register_abm{
    label = "Redstone Player Detection",
	nodenames = {"group:redstone_player_detection"},
	--neighbors = {"group:water"},
	interval = 0.2,
	chance = 1,
	action = function(pos)
		local found_player = false
		for _,object in ipairs(minetest.get_objects_inside_radius(pos, 9)) do
			if object:is_player() and object:get_hp() > 0 then
				local level = minetest.get_item_group(minetest.get_node(pos).name, "redstone_power")
				found_player = true
				local pos2 = object:get_pos()
				pos2 = vector.floor(vector.add(pos2,0.5))
				local distance = math.floor(vector.distance(pos2,pos))
				distance = math.abs(distance - 9)
				--print(distance)
				if level ~= distance then
					minetest.set_node(pos,{name="redstone:player_detector_"..distance})
					redstone.collect_info(pos)
					--print(distance)
				end
			end
		end
		if found_player == false then
			minetest.swap_node(pos,{name="redstone:player_detector_0"})
			redstone.collect_info(pos)
		end
	end,
}
]]--