--this removes power from node that the button is powering
local function on_button_destroy(pos)
	local param2 = minetest.get_node(pos).param2
	local dir = minetest.wallmounted_to_dir(param2)
	local pos = vector.add(dir,pos)
	local node = minetest.get_node(pos)
	local name = node.name
	local def = minetest.registered_nodes[name]
	
	if def.drawtype == "normal" and string.match(name, "redstone:node_activated_") then
		name = "main:"..string.gsub(name, "redstone:node_activated_", "")
		minetest.set_node(pos, {name=name})
		redstone.collect_info(pos)
	end
end


minetest.register_node("redstone:button_off", {
    description = "Button",
    tiles = {"stone.png"},
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,attached_node = 1,dig_immediate=1},
    sounds = main.stoneSound(),
    paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	drawtype= "nodebox",
	drop="redstone:button_off",
	node_box = {
		type = "fixed",
		fixed = {
				--left front bottom right back top
				{-0.25, -0.5,  -0.15, 0.25,  -0.3, 0.15},
			},
		},
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		minetest.set_node(pos, {name="redstone:button_on",param2=node.param2})
		local dir = minetest.wallmounted_to_dir(node.param2)
		local c_pos = table.copy(pos)
		local pos = vector.add(dir,pos)
		local name = minetest.get_node(pos).name
		local def = minetest.registered_nodes[name]
		
		if def.drawtype == "normal" and string.match(name, "main:") then
			minetest.sound_play("lever", {pos=pos})
			name = "redstone:node_activated_"..string.gsub(name, "main:", "")
			minetest.set_node(pos,{name=name})
			redstone.collect_info(pos)
		else
			minetest.sound_play("lever", {pos=pos,pitch=0.6})
		end
		
		local timer = minetest.get_node_timer(c_pos)
		timer:start(1)
	end,
	on_destruct = on_button_destroy,
})
minetest.register_node("redstone:button_on", {
    description = "Button",
    tiles = {"stone.png"},
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,attached_node = 1,dig_immediate=1},
    sounds = main.stoneSound(),
    paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	drawtype= "nodebox",
	drop="redstone:button_off",
	node_box = {
		type = "fixed",
		fixed = {
				--left front bottom right back top
				{-0.25, -0.5,  -0.15, 0.25,  -0.45, 0.15},
			},
		},
    on_timer = function(pos, elapsed)
		minetest.sound_play("lever", {pos=pos,pitch=0.8})
		local node = minetest.get_node(pos)
		minetest.set_node(pos, {name="redstone:button_off",param2=node.param2})
		on_button_destroy(pos)
	end,
	on_destruct = on_button_destroy,
})
