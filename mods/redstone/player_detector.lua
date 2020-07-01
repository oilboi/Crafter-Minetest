local
minetest,ipairs,math
=
minetest,ipairs,math

--detects players and outputs accordingly
for i = 0,16  do

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
