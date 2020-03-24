
local function repeater_toggle(pos,repeater_level)
	local old_power = get_powered_state_directional(pos)
	
	
	local param2 = minetest.get_node(pos).param2
	local input = minetest.facedir_to_dir(param2)
	input = vector.multiply(input,-1)
	input = vector.add(pos,input)
	local output = minetest.facedir_to_dir(param2)
	output = vector.add(pos,output)
	local input_node = minetest.get_node(input)
	local output_node = minetest.get_node(output)
	
	local self_repeater_level = minetest.get_node_group(minetest.get_node(pos).name, "repeater_level")
	
	if minetest.get_node_group(input_node.name, "redstone_power") == 0 then
		minetest.swap_node(pos,{name="redstone:repeater_off_"..self_repeater_level,param2=param2})
	elseif minetest.get_node_group(input_node.name, "redstone_power") > 0 then
		minetest.swap_node(pos,{name="redstone:repeater_on_"..self_repeater_level,param2=param2})
	end
	
	set_old_power(pos,old_power)
	
	--minetest.after(0.5, function(pos,param2,input,output,input_node,output_node)
	if minetest.get_node_group(output_node.name, "redstone_dust") > 0 then
		redstone.collect_info(output)
	elseif minetest.get_node_group(output_node.name, "repeater") > 0 then
		local timer = minetest.get_node_timer(output)
		timer:start(repeater_level/2)
	elseif minetest.get_node_group(output_node.name, "redstone_activation") > 0 then
		redstone.collect_info(output)
	end
	--end,pos,param2,input,output,input_node,output_node)
end

for level = 0,2 do
minetest.register_node("redstone:repeater_off_"..level, {
    description = "Redstone Repeater",
    tiles = {"repeater_off.png"},
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,attached_node = 1,repeater_off=1,repeater=1,redstone_activation_directional=1,repeater_level=level},
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
	--make the repeater turn on
	redstone_activation = function(pos)
		--repeater_toggle(pos)
		local timer = minetest.get_node_timer(pos)
		timer:start(level/2)
	end,
	on_timer = function(pos, elapsed)
		repeater_toggle(pos,level)
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local newlevel = level + 1
		if newlevel > 2 then
			newlevel = 0
		end
		minetest.swap_node(pos,{name="redstone:repeater_off_"..newlevel,param2=node.param2})
		minetest.sound_play("lever", {pos=pos,pitch=1-(newlevel*0.1)})
	end,
	redstone_deactivation = function(pos)
	end,
	redstone_update = function(pos)
	end,
	on_construct = function(pos)
	end,
	after_destruct  = function(pos)
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local timer = minetest.get_node_timer(pos)
		timer:start(level/2)
	end,
	on_dig = function(pos, node, digger)
		local param2 = minetest.get_node(pos).param2
		minetest.node_dig(pos, node, digger)
		local dir = minetest.facedir_to_dir(param2)
		redstone.collect_info(vector.add(pos,dir))
	end,
})

minetest.register_node("redstone:repeater_on_"..level, {
    description = "Redstone Repeater",
    tiles = {"repeater_on.png"},
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,attached_node = 1,redstone_activation_directional=1,repeater_on=1,repeater=1,torch_directional=1,redstone_power=9,repeater_level=level},
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
		minetest.swap_node(pos,{name="redstone:repeater_on_"..newlevel,param2=node.param2})
		minetest.sound_play("lever", {pos=pos,pitch=1-(newlevel*0.1)})
	end,
	redstone_activation = function(pos)
	end,
	redstone_deactivation = function(pos)
		--repeater_toggle(pos)
		local timer = minetest.get_node_timer(pos)
		timer:start(level/2)
	end,
	on_timer = function(pos, elapsed)
		repeater_toggle(pos,level)
	end,
	on_dig = function(pos, node, digger)
		repeater_toggle(pos,level)
		minetest.node_dig(pos, node, digger)
	end,
	redstone_update = function(pos)
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local timer = minetest.get_node_timer(pos)
		timer:start(level/2)
	end,
	on_construct = function(pos)
	end,
	after_destruct = function(pos)
	end,
	on_dig = function(pos, node, digger)
		local param2 = minetest.get_node(pos).param2
		minetest.node_dig(pos, node, digger)
		local dir = minetest.facedir_to_dir(param2)
		redstone.collect_info(vector.add(pos,dir))
	end,
})
end
