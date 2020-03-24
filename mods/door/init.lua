--this is a really lazy way to make a door and I'll improve it in the future
for _,material in pairs({"wood","iron"}) do
--this is the function that makes the door open and close
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
		minetest.set_node(pos,{name = "door:top".."_"..material,param2=dir})
	else
		pos.y = pos.y - 1
		minetest.set_node(pos,{name = "door:bottom".."_"..material,param2=dir})
	end
	minetest.sound_play("door", {pos=pos})--,pitch=math.random(80,100)/100})
end

--this is where the top and bottom of the door are created
for _,door in pairs({"top","bottom"}) do
	local tiles
	local groups
	local sounds
	local on_rightclick
	--make it so only the bottom activates
	
	if material == "wood" then
		sounds = main.woodSound()
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			door_move(pos)
		end
		if door == "bottom" then
			tiles = {"wood.png"}
			groups = {wood = 2, tree = 1, hard = 1, axe = 1, hand = 3, redstone_activation = 1}
		else
			tiles = {"wood.png","wood.png","wood.png","wood.png","wood_door_top.png","wood_door_top.png"}
			groups = {wood = 2, tree = 1, hard = 1, axe = 1, hand = 3}
		end
	elseif material == "iron" then
		sounds = main.stoneSound()
		if door == "bottom" then
			tiles = {"iron_block.png"}
			groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4, redstone_activation = 1}
		else
			tiles = {"iron_block.png","iron_block.png","iron_block.png","iron_block.png","iron_door_top.png","iron_door_top.png"}
			groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4}
		end
	end
	minetest.register_node("door:"..door.."_"..material, {
    description = material:gsub("^%l", string.upper).." Door",
    tiles = tiles,
    wield_image = "door_inv_"..material..".png",
    inventory_image = "door_inv_"..material..".png",
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    groups = groups,
    sounds = sounds,
    drop = "door:bottom".."_"..material,
    node_box = {
		type = "fixed",
		fixed = {
				--left front bottom right back top
				{-0.5, -0.5,  -0.5, 0.5,  0.5, -0.3},
			},
		},
	--redstone activation is in both because only the bottom is defined as an activator and it's easier to do it like this
    redstone_activation = function(pos)
		door_move(pos)
    end,
    redstone_deactivation = function(pos)
		door_move(pos)
    end,
    on_rightclick = on_rightclick,
    after_place_node = function(pos, placer, itemstack, pointed_thing)
		local node = minetest.get_node(pos)
		local param2 = node.param2
		pos.y = pos.y + 1
		if minetest.get_node(pos).name == "air" then
			minetest.set_node(pos,{name="door:top".."_"..material,param2=param2})
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
end
minetest.register_craft({
	output = "door:bottom_wood",
	recipe = {
		{"main:wood","main:wood"},
		{"main:wood","main:wood"},
		{"main:wood","main:wood"}
	}
})
minetest.register_craft({
	output = "door:bottom_iron",
	recipe = {
		{"main:iron","main:iron"},
		{"main:iron","main:iron"},
		{"main:iron","main:iron"}
	}
})

