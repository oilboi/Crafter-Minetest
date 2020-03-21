--create torch versions of the nodes
for name,def in pairs(minetest.registered_nodes) do
	if def.drawtype == "normal" and string.match(name, "main:") then
		local def2 = table.copy(def)
		def2.groups.redstone_torch = 1
		def2.drop = name
		def2.mod_origin = "redstone"
		def2.textures = "dirt.png"
		local newname = "redstone:"..string.gsub(name, "main:", "")
		def2.name = newname
		minetest.register_node(newname,def2)
	end
end


--this removes power from node that the switch is powering
local function on_lever_destroy(pos)
	local param2 = minetest.get_node(pos).param2
	local self = minetest.get_node(pos)
	local dir = minetest.wallmounted_to_dir(self.param2)
	
	local pos = vector.add(dir,pos)
	local node = minetest.get_node(pos)
	local name = node.name
	
	local def = minetest.registered_nodes[name]
	if def.drawtype == "normal" and string.match(name, "redstone:") then
		name = "main:"..string.gsub(name, "redstone:", "")
		minetest.set_node(pos, {name=name})
		redstone.collect_info(pos)
	end
end


minetest.register_node("redstone:switch_off", {
    description = "Crafting Table",
    tiles = {"stone.png"},
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,attached_node = 1},
    sounds = main.stoneSound(),
    paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	drawtype= "nodebox",
	drop="redstone:switch_off",
	node_box = {
		type = "fixed",
		fixed = {
				--left front bottom right back top
				{-0.3, -0.5,  -0.4, 0.3,  -0.4, 0.4},
				{-0.1, -0.5,  -0.3, 0.1,  0, -0.1},
			},
		},
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		minetest.sound_play("lever", {pos=pos})
		minetest.set_node(pos, {name="redstone:switch_on",param2=node.param2})
		local dir = minetest.wallmounted_to_dir(node.param2)
		local pos = vector.add(dir,pos)
		local name = minetest.get_node(pos).name
		print(name)
		local def = minetest.registered_nodes[name]
		
		if def.drawtype == "normal" and string.match(name, "main:") then
			name = "redstone:"..string.gsub(name, "main:", "")
			minetest.set_node(pos,{name=name})
			redstone.collect_info(pos)
		end
	end,
	on_destruct = on_lever_destroy,
})
minetest.register_node("redstone:switch_on", {
    description = "Crafting Table",
    tiles = {"stone.png"},
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,attached_node = 1},
    sounds = main.stoneSound(),
    paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	drawtype= "nodebox",
	drop="redstone:switch_off",
	node_box = {
		type = "fixed",
		fixed = {
				--left front bottom right back top
				{-0.3, -0.5,  -0.4, 0.3,  -0.4, 0.4},
				{-0.1, -0.5,  0.3, 0.1,  0, 0.1},
			},
		},
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		minetest.sound_play("lever", {pos=pos,pitch=0.8})
		minetest.set_node(pos, {name="redstone:switch_off",param2=node.param2})
		on_lever_destroy(pos)
	end,
	on_destruct = on_lever_destroy,
})
