local minetest = minetest
minetest.register_node("redstone:light_on", {
    description = "Redstone Light",
    tiles = {"redstone_light.png"},
    drawtype = "normal",
    light_source = 12,
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,pathable = 1,redstone_activation=1},
    sounds = main.stoneSound({
		footstep = {name = "glass_footstep", gain = 0.4},
        dug =  {name = "break_glass", gain = 0.4},
	}),
    drop = "redstone:light_off",
    redstone_activation = function(pos)
    end,
    redstone_deactivation = function(pos)
		minetest.set_node(pos,{name="redstone:light_off"})
    end,
})
minetest.register_node("redstone:light_off", {
    description = "Redstone Light",
    tiles = {"redstone_light.png"},
    drawtype = "normal",
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,pathable = 1,redstone_activation=1},
    sounds = main.stoneSound({
		footstep = {name = "glass_footstep", gain = 0.4},
        dug =  {name = "break_glass", gain = 0.4},
	}),
    drop = "redstone:light_off",
    redstone_activation = function(pos)
		minetest.set_node(pos,{name="redstone:light_on"})
    end,
    redstone_deactivation = function(pos)
    end,
})
