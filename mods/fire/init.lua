minetest.register_node("fire:fire", {
    description = "Fire",
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
    groups = {dig_immediate = 1,hurt_inside=2,fire=1},
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
			timer:start(math.random(0,2)+math.random())
		end
    end,
    on_timer = function(pos, elapsed)
	    local find_flammable = minetest.find_nodes_in_area(vector.subtract(pos,1), vector.add(pos,1), {"group:flammable"})
	    --print(dump(find_flammable))
	    
	    for _,p_pos in pairs(find_flammable) do
		    if math.random() > 0.9 then
				minetest.set_node(p_pos,{name="fire:fire"})
				local timer = minetest.get_node_timer(p_pos)
				timer:start(math.random(0,2)+math.random())
			end
	    end
	    
	    if math.random() > 0.85 then
			minetest.remove_node(pos)
		else
			local timer = minetest.get_node_timer(pos)
			timer:start(math.random(0,2)+math.random())
		end
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
	tool_capabilities = {
		groupcaps={
			_namespace_reserved = {times={[1]=5555}, uses=0, maxlevel=1},
		},
	},
	groups = {flint=1},
	sound = {breaks = {name="tool_break",gain=0.4}},
})

minetest.register_craft({
	type = "shapeless",
	output = "fire:flint_and_steel",
	recipe = {"main:flint","main:iron"},
})


local fire = {}

fire.initial_properties = {
	glow = -1,
	
}