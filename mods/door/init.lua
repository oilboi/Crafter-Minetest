--this is a really lazy way to make a door and I'll improve it in the future
local door_move = function(pos)
	local node = minetest.get_node(pos)
	local param2 = node.param2
	local name = string.gsub(node.name, "door:", "")
	local dir = minetest.facedir_to_dir(param2)
	local x = dir.z
	local z = dir.x
	local dir = minetest.dir_to_facedir(vector.new(x,0,z))
	minetest.set_node(pos,{name = "door:"..name,param2=dir})
	if string.match(node.name, ":bottom") then
		pos.y = pos.y + 1
		minetest.set_node(pos,{name = "door:top",param2=dir})
	else
		pos.y = pos.y - 1
		minetest.set_node(pos,{name = "door:bottom",param2=dir})
	end
	minetest.sound_play("door", {pos=pos})--,pitch=math.random(80,100)/100})
end
for _,door in pairs({"top","bottom"}) do
	local tiles
	local groups
	--make it so only the bottom activates
	if door == "bottom" then
		tiles = {"wood.png"}
		groups = {wood = 2, tree = 1, hard = 1, axe = 1, hand = 3, redstone_activation = 1}
	else
		tiles = {"wood.png","wood.png","wood.png","wood.png","door_top.png","door_top.png"}
		groups = {wood = 2, tree = 1, hard = 1, axe = 1, hand = 3}
	end
	minetest.register_node("door:"..door, {
    description = "Door",
    tiles = tiles,
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    groups = groups,
    sounds = main.woodSound(),
    drop = "door:bottom",
    node_box = {
		type = "fixed",
		fixed = {
				--left front bottom right back top
				{-0.5, -0.5,  -0.5, 0.5,  0.5, -0.3},
			},
		},
    redstone_activation = function(pos)
		door_move(pos)
    end,
    redstone_deactivation = function(pos)
		door_move(pos)
    end,
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		door_move(pos)
	end,
    after_place_node = function(pos, placer, itemstack, pointed_thing)
		local node = minetest.get_node(pos)
		local param2 = node.param2
		pos.y = pos.y + 1
		if minetest.get_node(pos).name == "air" then
			minetest.set_node(pos,{name="door:top",param2=param2})
		end
    end,	
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
		if string.match(oldnode.name, ":bottom") then
			pos.y = pos.y + 1
			minetest.remove_node(pos)
		else
			pos.y = pos.y - 1
			minetest.remove_node(pos)
		end
    end,
})
end
