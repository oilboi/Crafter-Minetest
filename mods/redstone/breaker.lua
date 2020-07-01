minetest.register_node("redstone:breaker_off", {
    description = "Breaker",
    tiles = {"redstone_piston.png^[invert:rgb",
    "redstone_piston.png^[transformR180^[invert:rgb",
    "redstone_piston.png^[transformR270^[invert:rgb",
    "redstone_piston.png^[transformR90^[invert:rgb",
    "wood.png^[invert:rgb",
    "stone.png^[invert:rgb"},
    paramtype2 = "facedir",
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,pathable = 1,redstone_activation=1},
    sounds = main.stoneSound(),
    drop = "redstone:breaker_off",
    paramtype = "light",
	sunlight_propagates = true,
	--reverse the direction to face the player
	on_construct = function(pos)
		redstone.inject(pos,{
			name = "redstone:breaker_off",
			activator = true,
		})
		redstone.update(pos)
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local look = clicker:get_look_dir()
		look = vector.multiply(look,-1)
		local dir = minetest.dir_to_facedir(look, true)
		minetest.swap_node(pos,{name="redstone:breaker_off",param2=dir})
		redstone.update(pos)
	end,
    after_place_node = function(pos, placer, itemstack, pointed_thing)
		local look = placer:get_look_dir()
		look = vector.multiply(look,-1)
		local dir = minetest.dir_to_facedir(look, true)
		minetest.swap_node(pos,{name="redstone:breaker_off",param2=dir})
	end,
	on_destruct = function(pos, oldnode)
		redstone.inject(pos,nil)
    end,
})

redstone.register_activator({
	name = "redstone:breaker_off",
    activate = function(pos)
       
        local node = minetest.get_node(pos)

        minetest.swap_node(pos,{name="redstone:breaker_on",param2=node.param2})

        local dir = minetest.facedir_to_dir(node.param2)

        redstone.inject(pos,{
			name = "redstone:breaker_on",
			activator = true,
		})

        pos = vector.add(pos,dir)

        node = minetest.get_node(pos)

        node = minetest.get_node_drops(node, "main:rubypick")

        if type(node) == "table" then
            for _,nodey in pairs(node) do
                minetest.throw_item(pos,nodey)
            end
        else
            minetest.throw_item(pos,node)
        end
        minetest.remove_node(pos)

        redstone.update(pos)
	end
})

minetest.register_lbm({
	name = "redstone:breaker_off",
	nodenames = {"redstone:breaker_off"},
	run_at_every_load = true,
	action = function(pos)
		redstone.inject(pos,{
			name = "redstone:breaker_off",
			activator = true,
        })
        redstone.update(pos)
	end,
})


minetest.register_node("redstone:breaker_on", {
    description = "Breaker",
    tiles = {"redstone_piston.png^[invert:rgb^[colorize:red:100",
    "redstone_piston.png^[transformR180^[invert:rgb^[colorize:red:100",
    "redstone_piston.png^[transformR270^[invert:rgb^[colorize:red:100",
    "redstone_piston.png^[transformR90^[invert:rgb^[colorize:red:100",
    "wood.png^[invert:rgb^[colorize:red:100",
    "stone.png^[invert:rgb^[colorize:red:100"},
    paramtype2 = "facedir",
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,pathable = 1,redstone_activation=1},
    sounds = main.stoneSound(),
    drop = "redstone:breaker_off",
    paramtype = "light",
	sunlight_propagates = true,
	--reverse the direction to face the player
	on_construct = function(pos)
		redstone.inject(pos,{
			name = "redstone:breaker_on",
			activator = true,
		})
		redstone.update(pos)
	end,
	on_destruct = function(pos)
		redstone.inject(pos,nil)
    end,
})


redstone.register_activator({
	name = "redstone:breaker_on",
    deactivate = function(pos)
        local node = minetest.get_node(pos)

        minetest.swap_node(pos,{name="redstone:breaker_off",param2=node.param2})
        redstone.inject(pos,{
			name = "redstone:breaker_off",
			activator = true,
        })
        redstone.update(pos)
    end,
})

minetest.register_lbm({
	name = "redstone:breaker_on",
	nodenames = {"redstone:breaker_on"},
	run_at_every_load = true,
	action = function(pos)
		redstone.inject(pos,{
			name = "redstone:breaker_on",
			activator = true,
		})
		redstone.update(pos)
	end,
})
