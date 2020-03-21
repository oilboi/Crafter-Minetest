
minetest.register_node("redstone:dust_powered",{
	description = "Redstone Dust",
	wield_image = "redstone_dust_item.png",
	tiles = {
		"redstone_dust_main.png^[colorize:red:255", "redstone_turn.png^[colorize:red:255",
		"redstone_t.png^[colorize:red:255", "redstone_cross.png^[colorize:red:255"
	},
	power=i,
	drawtype = "raillike",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	node_placement_prediction = "",
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
	groups={dig_immediate=1,attached=1,redstone=1,redstone_torch=1,redstone_hack=1},
	drop="redstone:dust",
	on_construct = function(pos)
		redstone.collect_info(pos)
	end,
	after_destruct = function(pos)
		--redstone.remove(pos,minetest.registered_nodes[minetest.get_node(pos).name].power)
		redstone.collect_info(pos)
	end,
	connects_to = {"group:redstone"},
})

for level = 0,2 do
minetest.register_node("redstone:repeater_off_"..level, {
    description = "Redstone Repeater",
    tiles = {"repeater_off.png"},
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,attached_node = 1,redstone_activation=1,repeater_off=level+1},
    sounds = main.stoneSound(),
    paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	drawtype= "nodebox",
	drop="redstone:repeater_off_0",
	node_box = {
		type = "fixed",
		fixed = {
				--left  front  bottom right back top
				{-0.5, -0.5,  -0.5, 0.5,  -0.3, 0.5}, --base
				{-0.1, -0.5,  0.2, 0.1,  0.1, 0.4}, --output post
				{-0.1, -0.5,  -0.05-(level*0.15)--[[]], 0.1,  0.1, 0.15-(level*0.15)--[[]]}, --input post
			},
		},
		
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local newlevel = level + 1
		if newlevel > 2 then
			newlevel = 0
		end
		minetest.set_node(pos,{name="redstone:repeater_off_"..newlevel,param2=node.param2})
		minetest.sound_play("lever", {pos=pos,pitch=1-(newlevel*0.1)})
	end,
	--make the repeater turn on
	redstone_activation = function(pos)
		local param2 = minetest.get_node(pos).param2
		local dir = minetest.facedir_to_dir(param2)
		--get inputs and outputs
		local input_pos = vector.add(pos,vector.multiply(dir,-1))
		local output_pos = vector.add(pos,dir)
		--check if powered redstone before
		if (minetest.get_node_group(minetest.get_node(input_pos).name, "redstone_dust") > 0 and minetest.get_node(input_pos).name ~= "redstone:dust_0") or minetest.get_node_group(minetest.get_node(input_pos).name, "repeater") > 0 then
			minetest.set_node(pos,{name="redstone:repeater_on_"..level,param2=param2})
			local timer = minetest.get_node_timer(pos)
			timer:start((level+1)/2)
		end
	end,
	redstone_deactivation = function(pos)
		--local param2 = minetest.get_node(pos).param2
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
minetest.register_node("redstone:repeater_on_"..level, {
    description = "Redstone Repeater",
    tiles = {"repeater_on.png"},
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,attached_node = 1,redstone_activation=1,repeater=level+1},
    sounds = main.stoneSound(),
    paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	drawtype= "nodebox",
	drop="redstone:repeater_off_0",
	node_box = {
		type = "fixed",
		fixed = {
				--left  front  bottom right back top
				{-0.5, -0.5,  -0.5, 0.5,  -0.3, 0.5}, --base
				{-0.1, -0.5,  0.2, 0.1,  0.1, 0.4}, --output post
				{-0.1, -0.5,  -0.05-(level*0.15)--[[]], 0.1,  0.1, 0.15-(level*0.15)--[[]]}, --input post
			},
		},
		
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local newlevel = level + 1
		if newlevel > 2 then
			newlevel = 0
		end
		minetest.set_node(pos,{name="redstone:repeater_on_"..newlevel,param2=node.param2})
		minetest.sound_play("lever", {pos=pos,pitch=1-(newlevel*0.1)})
	end,
	on_timer = function(pos)
		local param2 = minetest.get_node(pos).param2
		local dir = minetest.facedir_to_dir(param2)
		local input_pos = vector.add(pos,vector.multiply(dir,-1))
		local output_pos = vector.add(pos,dir)
		local output_node = minetest.get_node(output_pos)
		local input_node = minetest.get_node(input_pos)
		
		local repeater_output = minetest.get_node_group(output_node.name, "repeater_off")
		local dust_output = minetest.get_node_group(output_node.name, "redstone")
		
		if repeater_output > 0 then
			minetest.registered_nodes[output_node.name].redstone_activation(output_pos)
		elseif dust_output > 0 then
			minetest.set_node(output_pos, {name="redstone:dust_powered"})
		end
				
	end,
	redstone_activation = function(pos)
	end,
	redstone_deactivation = function(pos)
		minetest.after((level+1)/2,function(pos)
			local param2 = minetest.get_node(pos).param2
			local dir = minetest.facedir_to_dir(param2)
			--get inputs and outputs
			local input_pos = vector.add(pos,vector.multiply(dir,-1))
			local output_pos = vector.add(pos,dir)
			--check if powered redstone before
			if (minetest.get_node_group(minetest.get_node(input_pos).name, "redstone_dust") > 0 and minetest.get_node(input_pos).name == "redstone:dust_0") or minetest.get_node_group(minetest.get_node(input_pos).name, "repeater_off") > 0 then
				minetest.set_node(pos,{name="redstone:repeater_off_"..level,param2=param2})
				--check output node is repeater
				local output_node = minetest.get_node(output_pos)
				local repeater_output = minetest.get_node_group(output_node.name, "repeater")
				local dust_output = minetest.get_node_group(output_node.name, "redstone")
				if repeater_output > 0 then
					minetest.registered_nodes[output_node.name].redstone_deactivation(output_pos)
				elseif dust_output > 0 then
					minetest.set_node(output_pos, {name="redstone:dust_0"})
				end
			end
		end,pos)
		
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
end
