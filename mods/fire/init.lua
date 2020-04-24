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
    floodable = true,
    drop = "",
    walkable = false,
    is_ground_content = false,
    light_source = 11, --debugging
    on_construct = function(pos)
		local under = minetest.get_node(vector.new(pos.x,pos.y-1,pos.z)).name
		--makes nether portal
		if under == "nether:obsidian" then
			minetest.remove_node(pos)
			create_nether_portal(pos)
		--fire lasts forever on netherrack
		elseif under ~= "nether:netherrack" then
			local timer = minetest.get_node_timer(pos)
			timer:start(math.random(5,10))
		end
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
		if pointed_thing.type ~= "node" then
			return
		end
		if minetest.get_node(pointed_thing.above).name ~= "air" then
			minetest.sound_play("flint_failed", {pos=pointed_thing.above})
			return
		end
		
		--can't make fire in the aether
		if pointed_thing.above.y >= 20000 then
			minetest.sound_play("flint_failed", {pos=pointed_thing.above,pitch=math.random(75,95)/100})
			return
		end
		
		minetest.add_node(pointed_thing.above,{name="fire:fire"})
		minetest.sound_play("flint_and_steel", {pos=pointed_thing.above})
		itemstack:add_wear(100)
		return(itemstack)
	end,
	sound = {breaks = {name="tool_break",gain=0.4}},
})

minetest.register_craft({
	type = "shapeless",
	output = "fire:flint_and_steel",
	recipe = {"main:flint","main:iron"},
})
