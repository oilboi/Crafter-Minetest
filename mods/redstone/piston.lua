local minetest,math,ipairs,vector,table = minetest,math,ipairs,vector,table
--exclude certain mods and nodes from being pushed and pulled to stop glitches
local registered_nodes
minetest.register_on_mods_loaded(function()
	registered_nodes  = minetest.registered_nodes
end)

local excluded_mods = {utility=true,craftingtable=true,buildtest=true,sign=true,bed=true}
local excluded_nodes = {
	["redstone:piston_on"]=true,
	["redstone:sticky_piston_on"]=true,
	["redstone:actuator"]=true,
	["redstone:sticky_actuator"]=true,
	["redstone:inverter_on"]=true,
	["redstone:inverter_off"]=true,
	["redstone:torch_wall"]=true,
	["redstone:torch_floor"]=true,
	["redstone:lever_on"]=true,
	["redstone:lever_off"]=true,
	["redstone:button_on"]=true,
	["redstone:button_off"]=true,
}
for i = 0,8 do
	excluded_nodes["redstone:dust_"..i] = true
end
for i = 0,7 do
	excluded_nodes["redstone:repeater_on_"..i] = true
	excluded_nodes["redstone:repeater_off_"..i] = true
end
for i = 0,9 do
	excluded_nodes["redstone:comparator_"..i] = true
end
for i = 0,9 do
	excluded_nodes["redstone:pressure_plate_"..i] = true
end
for i = 0,1 do
	excluded_nodes["redstone:ore_"..i] = true
end


--[[
███████╗██╗   ██╗███╗   ██╗ ██████╗████████╗██╗ ██████╗ ███╗   ██╗
██╔════╝██║   ██║████╗  ██║██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║
█████╗  ██║   ██║██╔██╗ ██║██║        ██║   ██║██║   ██║██╔██╗ ██║
██╔══╝  ██║   ██║██║╚██╗██║██║        ██║   ██║██║   ██║██║╚██╗██║
██║     ╚██████╔╝██║ ╚████║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║
╚═╝      ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
]]

--this is how the piston pushes nodes
local move_index
local space
local index_pos
local node
local param2
local def
local push
local index
local function push_nodes(pos,dir)
	move_index = {}
	space = false
	for i = 1,30 do
		index_pos = vector.add(vector.multiply(dir,i),pos)
		node = minetest.get_node(index_pos)
		param2 = node.param2
		def = minetest.registered_nodes[node.name]
		name = node.name
		push = ((excluded_mods[def.mod_origin] ~= true) and (excluded_nodes[name] ~= true))
		if push and name ~= "air" then
			index = {}
			index.pos = index_pos
			index.name = name
			index.param2 = param2
			table.insert(move_index,index)
		elseif name == "air" then
			space = true
			break
		else
			space = false
			break
		end		
	end

	--check if room to move and objects in log
	if space == true and next(move_index) then
		if table.getn(move_index) == 1 and minetest.get_item_group(move_index[1].name, "falling_node") > 0 then
			for i = 1,table.getn(move_index) do
				print("trying")
				move_index[i].pos = vector.add(move_index[i].pos,dir)
				minetest.set_node(move_index[i].pos,{name="air"})

				local obj = minetest.add_entity(vector.add(move_index[i].pos,dir), "__builtin:falling_node")
				obj:get_luaentity():set_node({name=move_index[i].name})
				obj:set_velocity(vector.multiply(dir,19))
			end
		else
			for i = 1,table.getn(move_index) do
				move_index[i].pos = vector.add(move_index[i].pos,dir)
				minetest.set_node(move_index[i].pos,move_index[i])
				minetest.check_for_falling(move_index[i].pos)
			end
		end
	end
	return(space)
end

--this is the logic of the piston
local facedir
local dir
local piston_location
local worked
local function actuator_arm_function(pos)
	--this is where the piston activates
	facedir = minetest.get_node(pos).param2
	dir = minetest.facedir_to_dir(facedir)
	piston_location = vector.add(pos,dir)
	worked = push_nodes(pos,dir)
	local node = minetest.get_node(vector.add(pos,dir)).name
	
	if worked == true then
		--push player
		if node == "air" then
			for _,object in ipairs(minetest.get_objects_inside_radius(piston_location, 2)) do

				if object:is_player() and object:get_hp() > 0 then
					local pos2 = object:get_pos()
					local compare = vector.subtract(pos2,piston_location)
					local real_y = compare.y
					compare = vector.abs(compare)
					--piston pointing up
					if dir.y == 1 then
						if compare.y <= 0.5 and compare.x < 0.8 and compare.z < 0.8 then
							object:move_to(vector.add(dir,pos2))
							object:add_player_velocity(vector.multiply(dir,20))
						end
					--piston sideways
					elseif dir.x ~=0 or dir.z ~= 0 then
						if real_y <= 0.5 and real_y >= -1.6 and compare.x < 0.8 and compare.z < 0.8 then
							object:move_to(vector.add(dir,pos2))
							object:add_player_velocity(vector.multiply(dir,19))
						end
					end
				elseif not object:is_player() and object:get_luaentity().name == "__builtin:falling_node" then
					local pos2 = object:get_pos()
					local compare = vector.subtract(pos2,piston_location)
					local real_y = compare.y
					compare = vector.abs(compare)
					if compare.y <= 1.5 and compare.x <= 1.5 and compare.z <= 1.5 then
						object:move_to(vector.add(dir,pos2))
						object:add_velocity(vector.multiply(dir,20))
					end
				elseif not object:is_player() and object:get_luaentity().name == "__builtin:item" then
					local pos2 = object:get_pos()
					local compare = vector.subtract(pos2,piston_location)
					local real_y = compare.y
					compare = vector.abs(compare)
					if compare.y <= 1 and compare.x <= 1 and compare.z <= 1 then
						object:move_to(vector.add(dir,pos2))
						object:add_velocity(vector.multiply(dir,20))
						object:get_luaentity().poll_timer = 0
					end
				end
			end
		end
		minetest.sound_play("piston", {pos=pos,pitch=math.random(85,100)/100})
		minetest.set_node(piston_location,{name="redstone:actuator",param2=facedir})
		minetest.swap_node(pos,{name="redstone:piston_on",param2=facedir})

		redstone.inject(pos,{
			name = "redstone:piston_on",
			activator = true,
		})
		minetest.after(0,function()
			redstone.update(pos)
		end)
	end
end


--[[
 ██████╗ ███████╗███████╗
██╔═══██╗██╔════╝██╔════╝
██║   ██║█████╗  █████╗  
██║   ██║██╔══╝  ██╔══╝  
╚██████╔╝██║     ██║     
 ╚═════╝ ╚═╝     ╚═╝     
]]


minetest.register_node("redstone:piston_off", {
    description = "Piston",
    tiles = {"redstone_piston.png","redstone_piston.png^[transformR180","redstone_piston.png^[transformR270","redstone_piston.png^[transformR90","wood.png","stone.png"},
    paramtype2 = "facedir",
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,pathable = 1,redstone_activation=1},
    sounds = main.stoneSound(),
    drop = "redstone:piston_off",
    paramtype = "light",
	sunlight_propagates = true,
    --reverse the direction to face the player
    after_place_node = function(pos, placer, itemstack, pointed_thing)
		local look = placer:get_look_dir()
		look = vector.multiply(look,-1)
		local dir = minetest.dir_to_facedir(look, true)
		minetest.swap_node(pos,{name="redstone:piston_off",param2=dir})
		redstone.inject(pos,{
			name = "redstone:piston_off",
			activator = true,
		})
		redstone.update(pos)
	end,
	after_destruct = function(pos, oldnode)
		redstone.inject(pos,nil)
    end,
})


redstone.register_activator({
	name = "redstone:piston_off",
	activate = function(pos)
		actuator_arm_function(pos)
	end
})

minetest.register_lbm({
	name = "redstone:piston_off",
	nodenames = {"redstone:piston_off"},
	run_at_every_load = true,
	action = function(pos)
		redstone.inject(pos,{
			name = "redstone:piston_off",
			activator = true,
		})
		minetest.after(0,function()
			redstone.update(pos)
		end)
	end,
})


--[[
 ██████╗ ███╗   ██╗
██╔═══██╗████╗  ██║
██║   ██║██╔██╗ ██║
██║   ██║██║╚██╗██║
╚██████╔╝██║ ╚████║
 ╚═════╝ ╚═╝  ╚═══╝
]]

minetest.register_node("redstone:piston_on", {
    description = "Piston",
    tiles = {"redstone_piston.png","redstone_piston.png^[transformR180","redstone_piston.png^[transformR270","redstone_piston.png^[transformR90","stone.png","stone.png"},
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,pathable = 1,redstone_activation=1},
    sounds = main.stoneSound(),
    drop = "redstone:piston_off",
    node_box = {
		type = "fixed",
		fixed = {
				--left front bottom right back top
				{-0.5, -0.5,  -0.5, 0.5,  0.5, 3/16},
			},
		},
    after_destruct = function(pos, oldnode)
		local facedir = oldnode.param2
		local dir = minetest.facedir_to_dir(facedir)
		local piston_location = vector.add(pos,dir)
		minetest.remove_node(piston_location)
		redstone.inject(pos,nil)
    end,
})

minetest.register_lbm({
	name = "redstone:piston_on",
	nodenames = {"redstone:piston_on"},
	run_at_every_load = true,
	action = function(pos)
		redstone.inject(pos,{
			name = "redstone:piston_on",
			activator = true,
		})
		minetest.after(0,function()
			redstone.update(pos)
		end)
	end,
})

redstone.register_activator({
	name = "redstone:piston_on",
	deactivate = function(pos)
		--this is where the piston deactivates
		local facedir = minetest.get_node(pos).param2
		local dir = minetest.facedir_to_dir(facedir)
		local piston_location = vector.add(pos,dir)
		minetest.remove_node(piston_location)
		minetest.swap_node(pos,{name="redstone:piston_off",param2=facedir})
		piston_location.y = piston_location.y + 1
		minetest.sound_play("piston", {pos=pos,pitch=math.random(85,100)/100})
		redstone.inject(pos,{
			name = "redstone:piston_off",
			activator = true,
		})
	end
})


--[[
 █████╗ ██████╗ ███╗   ███╗
██╔══██╗██╔══██╗████╗ ████║
███████║██████╔╝██╔████╔██║
██╔══██║██╔══██╗██║╚██╔╝██║
██║  ██║██║  ██║██║ ╚═╝ ██║
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝
]]



minetest.register_node("redstone:actuator", {
    description = "Piston Actuator",
    tiles = {"wood.png"},
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,pathable = 1},
    sounds = main.stoneSound(),
    drop = "redstone:piston_off",
    node_box = {
		type = "fixed",
		fixed = {
				--left front bottom right back top
				{-0.5, -0.5,  0.2, 0.5,  0.5, 0.5}, --mover
				{-0.15, -0.15,  -0.9, 0.15,  0.15, 0.5}, --actuator
			},
		},
	after_destruct = function(pos, oldnode)
		local facedir = oldnode.param2
		local dir = minetest.facedir_to_dir(facedir)
		dir = vector.multiply(dir,-1)
		local piston_location = vector.add(pos,dir)
		minetest.remove_node(piston_location)
    end,
})

--[[
-------------------------------------------------------------------------------------------------------------------------------------------------------
--this is how the piston pushes nodes
local function sticky_piston_push_nodes(pos,dir)
	local move_index = {}
	local space = false
	for i = 1,30 do
		local index_pos = vector.multiply(dir,i)
		local index_pos = vector.add(index_pos,pos)
		local node = minetest.get_node(index_pos)
		local param2 = node.param2
		local def = minetest.registered_nodes[node.name]
		local name = node.name
		local push = ((excluded_mods[def.mod_origin] ~= true) and (excluded_nodes[name] ~= true))
		if push and name ~= "air" then
			local index = {}
			index.pos = index_pos
			index.name = name
			index.param2 = param2
			table.insert(move_index,index)
		elseif name == "air" then
			space = true
			break
		else
			space = false
			break
		end		
	end
	--check if room to move and objects in log
	if space == true and next(move_index) then
		for i = 1,table.getn(move_index) do
			move_index[i].pos = vector.add(move_index[i].pos,dir)
			minetest.set_node(move_index[i].pos,{name=move_index[i].name,param2=move_index[i].param2})
		end
	end
	return(space)
end

--this is the logic of the piston
local function sticky_piston_push(pos)
	--this is where the piston activates
	local facedir = minetest.get_node(pos).param2
	local dir = minetest.facedir_to_dir(facedir)
	local piston_location = vector.add(pos,dir)
	local worked = sticky_piston_push_nodes(pos,dir)
	local node = minetest.get_node(vector.add(pos,dir)).name
	if worked == true then
		--push player
		if node == "air" then
			for _,object in ipairs(minetest.get_objects_inside_radius(piston_location, 2)) do
				if object:is_player() and object:get_hp() > 0 then
					local pos2 = object:get_pos()
					local compare = vector.subtract(pos2,piston_location)
					local real_y = compare.y
					compare = vector.abs(compare)
					--piston pointing up
					if dir.y == 1 then
						if compare.y <= 0.5 and compare.x < 0.8 and compare.z < 0.8 then
							object:move_to(vector.add(dir,pos2))
							--object:add_player_velocity(vector.multiply(dir,20))
						end
					--piston sideways
					elseif dir.x ~=0 or dir.z ~= 0 then
						if real_y <= 0.5 and real_y >= -1.6 and compare.x < 0.8 and compare.z < 0.8 then
							object:move_to(vector.add(dir,pos2))
							--object:add_player_velocity(vector.multiply(dir,20))
						
						end
					end
				end
			end
		end
		minetest.sound_play("piston", {pos=pos,pitch=math.random(85,100)/100})
		minetest.set_node(piston_location,{name="redstone:sticky_actuator",param2=facedir})
		minetest.set_node(pos,{name="redstone:sticky_piston_on",param2=facedir})
	end
end



--this is how sticky pistons pull nodes
local function sticky_piston_pull_nodes(pos,dir)
	
	local move_index = {}
	local index_pos = vector.add(pos,dir)
	
	local node = minetest.get_node(index_pos)
	local param2 = node.param2
	local def = minetest.registered_nodes[node.name]
	local name = node.name
	local pull = ((excluded_mods[def.mod_origin] ~= true) and (excluded_nodes[name] ~= true))
	--if it can be pulled pull it
	if pull and name ~= "air" then
		minetest.remove_node(index_pos)
		minetest.set_node(pos,{name=name,param2=param2})
	end
end

------------------------------[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[

--this is the logic of the sticky piston on return
local function sticky_piston_pull(pos,dir)
	--this is where the piston activates
	--local facedir = minetest.get_node(pos).param2
	--local dir = minetest.facedir_to_dir(facedir)
	--local piston_location = vector.add(pos,dir)
	
	local in_front_pos = vector.add(pos,dir)
	
	local node = minetest.get_node(in_front_pos).name
	--pull nodes
	sticky_piston_pull_nodes(pos,dir)
	
	--pull player
	if node == "air" then
		for _,object in ipairs(minetest.get_objects_inside_radius(in_front_pos, 2)) do
			if object:is_player() and object:get_hp() > 0 then
				local pos2 = object:get_pos()
				local compare = vector.subtract(pos2,in_front_pos)
				local real_y = compare.y
				compare = vector.abs(compare)
				--piston pointing up
				if dir.y == 1 then
					if compare.y <= 0.5 and compare.x < 0.8 and compare.z < 0.8 then
						dir = vector.multiply(dir,-1)
						object:move_to(vector.add(dir,pos2))
						--object:add_player_velocity(vector.multiply(dir,20))
					end
				--piston sideways
				elseif dir.x ~=0 or dir.z ~= 0 then
					if real_y <= 0.5 and real_y >= -1.6 and compare.x < 0.8 and compare.z < 0.8 then
						dir = vector.multiply(dir,-1)
						object:move_to(vector.add(dir,pos2))
						--object:add_player_velocity(vector.multiply(dir,20))
					
					end
				end
			end
		end
	end
	minetest.sound_play("piston", {pos=pos,pitch=math.random(85,100)/100})
	--minetest.set_node(piston_location,{name="redstone:sticky_actuator",param2=facedir})
	--minetest.set_node(pos,{name="redstone:sticky_piston_on",param2=facedir})
end

------------------------------[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[

minetest.register_node("redstone:sticky_piston_off", {
    description = "Sticky Piston",
    tiles = {"redstone_piston.png","redstone_piston.png^[transformR180","redstone_piston.png^[transformR270","redstone_piston.png^[transformR90","sticky_piston.png","stone.png"},
    paramtype2 = "facedir",
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,pathable = 1,redstone_activation=1},
    sounds = main.stoneSound(),
    drop = "redstone:sticky_piston_off",
    paramtype = "light",
    sunlight_propagates = true,
    redstone_activation = function(pos)
		if minetest.get_node(pos).name == "redstone:sticky_piston_off" then
			sticky_piston_push(pos)
		end
    end,
    --reverse the direction to face the player
    after_place_node = function(pos, placer, itemstack, pointed_thing)
		local look = placer:get_look_dir()
		look = vector.multiply(look,-1)
		local dir = minetest.dir_to_facedir(look, true)
		minetest.set_node(pos,{name="redstone:sticky_piston_off",param2=dir})
		redstone.collect_info(pos)
    end,
})


--------------------------


minetest.register_node("redstone:sticky_piston_on", {
    description = "Sticky Piston",
    tiles = {"redstone_piston.png","redstone_piston.png^[transformR180","redstone_piston.png^[transformR270","redstone_piston.png^[transformR90","stone.png","stone.png"},
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,pathable = 1,redstone_activation=1},
    sounds = main.stoneSound(),
    drop = "redstone:sticky_piston_off",
    node_box = {
		type = "fixed",
		fixed = {
				--left front bottom right back top
				{-0.5, -0.5,  -0.5, 0.5,  0.5, 3/16},
			},
		},
    redstone_deactivation = function(pos)
		--this is where the piston deactivates
		local facedir = minetest.get_node(pos).param2
		local dir = minetest.facedir_to_dir(facedir)
		local piston_location = vector.add(pos,dir)
		minetest.remove_node(piston_location)
		minetest.set_node(pos,{name="redstone:sticky_piston_off",param2=facedir})
		
		sticky_piston_pull(piston_location,dir)
		
		piston_location.y = piston_location.y + 1
		minetest.punch_node(piston_location)
		--minetest.sound_play("piston", {pos=pos,pitch=math.random(85,100)/100})
    end,
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local facedir = oldnode.param2
		local dir = minetest.facedir_to_dir(facedir)
		local piston_location = vector.add(pos,dir)
		minetest.remove_node(piston_location)
    end,
})

minetest.register_node("redstone:sticky_actuator", {
    description = "Redstone Piston",
    tiles = {"wood.png","wood.png","wood.png","wood.png","sticky_piston.png","wood.png"},
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,pathable = 1},
    sounds = main.stoneSound(),
    drop = "redstone:sticky_piston_off",
    node_box = {
		type = "fixed",
		fixed = {
				--left front bottom right back top
				{-0.5, -0.5,  0.2, 0.5,  0.5, 0.5}, --mover
				{-0.15, -0.15,  -0.9, 0.15,  0.15, 0.5}, --actuator
			},
		},
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local facedir = oldnode.param2
		local dir = minetest.facedir_to_dir(facedir)
		dir = vector.multiply(dir,-1)
		local piston_location = vector.add(pos,dir)
		minetest.remove_node(piston_location)
    end,
})
]]--

