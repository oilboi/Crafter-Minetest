local function comparator_logic(pos)
	
	local old_power = get_powered_state_directional(pos)
	
	local param2 = minetest.get_node(pos).param2
	local dir = minetest.facedir_to_dir(param2)
	local get_group = minetest.get_item_group
	
	--get inputs and outputs
	local input_pos_straight = vector.subtract(pos,dir)
	
	--if you're reading this, this is an easy way to get 90 degrees from a direction (math.pi would be 180 degrees which you can simply -1 multiply the direction instead)
	local input_pos_right = vector.add(minetest.yaw_to_dir(minetest.dir_to_yaw(dir)-(math.pi/2)),pos)
	local input_pos_left = vector.add(minetest.yaw_to_dir(minetest.dir_to_yaw(dir)+(math.pi/2)),pos)
	
	local output_pos = vector.add(pos,dir)
	local output = false
	
	local comparator_level = get_group(minetest.get_node(pos).name, "comparator")
	
	local input_level = get_group(minetest.get_node(input_pos_straight).name, "redstone_power")
	local output_level = get_group(minetest.get_node(output_pos).name, "redstone_power")
	
	--this prefers right to left--
	
	local output_node = minetest.get_node(output_pos).name
	local input_node_straight = minetest.get_node(input_pos_straight).name
	
	local left_level = get_group(minetest.get_node(input_pos_left).name, "redstone_power")
	local right_level = get_group(minetest.get_node(input_pos_right).name, "redstone_power")
	
	local compare_level = 0
	if right_level > compare_level then
		compare_level = right_level
	end
	if left_level > compare_level then
		compare_level = left_level
	end	
	local new_output_level = 0
	
	if input_level > compare_level then
		new_output_level = 9
	elseif input_level <= compare_level then
		new_output_level = 0
	end
	
	--charge
	if input_level > 0 then--and output_level ~= new_output_level-1 then
		if comparator_level ~= new_output_level then
			--print("comparator on")
			minetest.swap_node(pos, {name="redstone:comparator_"..new_output_level,param2=param2})
			redstone.collect_info(output_pos)
		end
	elseif output_level ~= new_output_level-1 then
		if comparator_level ~= new_output_level then
			--print("comparator off")
			minetest.swap_node(pos, {name="redstone:comparator_"..new_output_level,param2=param2})
			redstone.collect_info(output_pos)
		end
	end
	
	set_old_power(pos,old_power)
end


for i = 0,9 do
	minetest.register_node("redstone:comparator_"..i, {
		description = "Redstone Comparator",
		tiles = {"repeater_on.png"},
		groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,attached_node = 1,redstone_activation_directional=1,torch_directional=1,redstone_power=i,comparator=i},
		sounds = main.stoneSound(),
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		walkable = false,
		drawtype= "nodebox",
		drop="redstone:comparator_0",
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
		redstone_activation = function(pos)
			comparator_logic(pos)
		end,
		redstone_deactivation = function(pos)
			comparator_logic(pos)
		end,
		redstone_update = function(pos)
			comparator_logic(pos)
		end,
		on_construct = function(pos)
		end,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			redstone.collect_info(pos)
		end,
		on_dig = function(pos, node, digger)
			local param2 = minetest.get_node(pos).param2
			minetest.node_dig(pos, node, digger)
			local dir = minetest.facedir_to_dir(param2)
			redstone.collect_info(vector.add(pos,dir))
		end,
		after_destruct = function(pos)
		end,
	})
end


