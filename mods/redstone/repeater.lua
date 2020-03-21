minetest.register_node("redstone:repeater", {
    description = "Crafting Table",
    tiles = {"stone.png"},
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,attached_node = 1},
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
		minetest.sound_play("lever", {pos=pos})
		minetest.set_node(pos, {name="redstone:button_on",param2=node.param2})
		local dir = minetest.facedir_to_dir(node.param2)
		local c_pos = table.copy(pos)
		local pos = vector.add(dir,pos)
		local name = minetest.get_node(pos).name
		local def = minetest.registered_nodes[name]
		
		if def.drawtype == "normal" and string.match(name, "main:") then
			name = "redstone:"..string.gsub(name, "main:", "")
			minetest.set_node(pos,{name=name})
			redstone.collect_info(pos)
			local timer = minetest.get_node_timer(c_pos)
			timer:start(1)
		end
	end,
	on_destruct = on_button_destroy,
})
