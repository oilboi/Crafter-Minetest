minetest.register_node("fire:fire", {
    description = "How did you even get this?",
    drawtype = "firelike",
	tiles = {
		{
			name = "fire.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.3
			},
		},
	},
	inventory_image = "fire.png",
    groups = {dig_immediate = 1},
    sounds = main.stoneSound(),
    drop = "",
    walkable = false,
    is_ground_content = false,
    light_source = 11, --debugging
    on_construct = function(pos)
		local timer = minetest.get_node_timer(pos)
		timer:start(math.random(5,10))
    end,
    on_timer = function(pos, elapsed)
		minetest.remove_node(pos)
    end,
})


minetest.register_abm({
	label = "Fire Spread",
	nodenames = {"group:flammable"},
	neighbors = {"fire:fire"},
	interval = 0.25,
	chance = 15.0,
	catch_up = false,
	action = function(pos)
		minetest.set_node(pos,{name="fire:fire"})
	end,
})
