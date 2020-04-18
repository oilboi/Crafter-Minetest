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

--flint and steel
minetest.register_tool("fire:flint_and_steel", {
	description = "Flint and Steel",
	inventory_image = "flint_and_steel.png",
	on_place = function(itemstack, placer, pointed_thing)
		minetest.add_node(pointed_thing.above,{name="fire:fire"})
		minetest.sound_play("flint_and_steel", {pos=pointed_thing.above})
		itemstack:add_wear(100)
		return(itemstack)
	end,
	sound = {breaks = {name="tool_break",gain=0.4}},
})
