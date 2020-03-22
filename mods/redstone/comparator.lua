local function comparator_logic(pos)
	local param2 = minetest.get_node(pos).param2
	local dir = minetest.facedir_to_dir(param2)
	
	--get inputs and outputs
	local input_pos_straight = vector.subtract(pos,dir)
	
	--if you're reading this, this is an easy way to get 90 degrees from a direction (math.pi would be 180 degrees which you can simply -1 multiply the direction instead)
	local input_pos_right = vector.add(minetest.yaw_to_dir(minetest.dir_to_yaw(dir)-(math.pi/2)),pos)
	local input_pos_left = vector.add(minetest.yaw_to_dir(minetest.dir_to_yaw(dir)+(math.pi/2)),pos)
	
	local output_pos = vector.add(pos,dir)
	local output = false
	
	local input_level = string.gsub(minetest.get_node(input_pos_straight).name, "redstone:dust_", "")
	local output_level = string.gsub(minetest.get_node(output_pos).name, "redstone:dust_", "")
	
	input_level = tonumber(input_level)
	output_level = tonumber(output_level)
	
	local getgroup = minetest.get_node_group
	--this prefers right to left--
	
	local output_node = minetest.get_node(output_pos).name
	local input_node_straight = minetest.get_node(input_pos_straight).name
	
	local left_level = string.gsub(minetest.get_node(input_pos_left).name, "redstone:dust_", "")
	local right_level = string.gsub(minetest.get_node(input_pos_right).name, "redstone:dust_", "")
	
	left_level = tonumber(left_level)
	right_level = tonumber(right_level)
	
	local compare_level = 0
	if type(right_level) == "number" then
		if right_level > compare_level then
			compare_level = right_level
		end
	end
	if type(left_level) == "number" then
		if left_level > compare_level then
			compare_level = left_level
		end
	end
		
	--charge
	if getgroup(input_node_straight,"redstone_dust")>0 and getgroup(output_node,"redstone_dust")>0 then
		if input_level > 0 and input_level >= compare_level then
			minetest.set_node(output_pos, {name="redstone:dust_powered"})
		else
			minetest.set_node(output_pos, {name="redstone:dust_0"})
		end
	end
	--discharge
	if getgroup(input_node_straight,"redstone_dust")>0 and getgroup(output_node,"redstone_hack")>0 then
		if input_level == 0 then
			minetest.set_node(output_pos, {name="redstone:dust_0"})
		end
	end
end



minetest.register_node("redstone:comparator", {
    description = "Redstone Comparator",
    tiles = {"repeater_on.png"},
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,attached_node = 1,redstone_activation=1},
    sounds = main.stoneSound(),
    paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	drawtype= "nodebox",
	drop="redstone:comparator",
	node_box = {
		type = "fixed",
		fixed = {
				--left  front  bottom right back top
				{-0.5, -0.5,  -0.5, 0.5,  -0.3, 0.5}, --base
				{-0.1, -0.5,  0.2, 0.1,  0.1, 0.4}, --output post
				{-0.4, -0.5,  -0.35, -0.2,  0.1, -0.15}, --input post
				{0.4, -0.5,  -0.35, 0.2,  0.1, -0.15}, --input post
			},
		},
	--[[
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local newlevel = level + 1
		if newlevel > 2 then
			newlevel = 0
		end
		minetest.set_node(pos,{name="redstone:repeater_off_"..newlevel,param2=node.param2})
		minetest.sound_play("lever", {pos=pos,pitch=1-(newlevel*0.1)})
	end,
	]]
	redstone_activation = function(pos)
		comparator_logic(pos)
	end,
	redstone_deactivation = function(pos)
		comparator_logic(pos)
	end,
	on_construct = function(pos)
		redstone.collect_info(pos)
	end,
	on_destruct = function(pos)
		--redstone.remove(pos,minetest.registered_nodes[minetest.get_node(pos).name].power)
		local param2 = minetest.get_node(pos).param2
		local dir = minetest.facedir_to_dir(param2)
		local output_pos = vector.add(pos,dir)
		--check if powered redstone before
		if minetest.get_node_group(minetest.get_node(output_pos).name, "repeater") > 0 then
			local timer = minetest.get_node_timer(output_pos)
			timer:start((level+1)/2)
		elseif minetest.get_node_group(minetest.get_node(output_pos).name, "redstone_hack") > 0 then
			minetest.set_node(output_pos, {name="redstone:dust_0"})
		end
		redstone.collect_info(output_pos)
	end,
})


