--only allow pistons to move "main" nodes
local function piston_move(pos,dir)
	local move_index = {}
	local space = false
	for i = 1,30 do
		local index_pos = vector.multiply(dir,i)
		local index_pos = vector.add(index_pos,pos)
		local node = minetest.get_node(index_pos)
		local def = minetest.registered_nodes[node.name]
		local name = node.name
		if def.drawtype == "normal" and string.match(name, "main:") then
			local index = {}
			index.pos = index_pos
			index.name = name
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
			minetest.set_node(move_index[i].pos,{name=move_index[i].name})
		end
	end
	return(space)
end

minetest.register_node("redstone:piston_off", {
    description = "Redstone Piston",
    tiles = {"redstone_piston.png","redstone_piston.png^[transformR180","redstone_piston.png^[transformR270","redstone_piston.png^[transformR90","wood.png","stone.png"},
    paramtype2 = "facedir",
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,pathable = 1,redstone_activation=1},
    sounds = main.stoneSound(),
    drop = "redstone:piston_off",
    paramtype = "light",
    sunlight_propagates = true,
    redstone_activation = function(pos)
		--this is where the piston activates
		local facedir = minetest.get_node(pos).param2
		local dir = minetest.facedir_to_dir(facedir)
		local piston_location = vector.add(pos,dir)
		local worked = piston_move(pos,dir)
		if worked == true then
			--push player
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
							object:add_player_velocity(vector.multiply(dir,20))
						
						end
					end
				end
			end
			minetest.sound_play("piston", {pos=pos,pitch=math.random(85,100)/100})
			minetest.set_node(piston_location,{name="redstone:actuator",param2=facedir})
			minetest.set_node(pos,{name="redstone:piston_on",param2=facedir})
		end
    end,
    --reverse the direction to face the player
    after_place_node = function(pos, placer, itemstack, pointed_thing)
		local look = placer:get_look_dir()
		look = vector.multiply(look,-1)
		dir = minetest.dir_to_facedir(look, true)
		minetest.set_node(pos,{name="redstone:piston_off",param2=dir})
		redstone.collect_info(pos)
    end,
})
minetest.register_node("redstone:piston_on", {
    description = "Redstone Piston",
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
    redstone_deactivation = function(pos)
		--this is where the piston deactivates
		local facedir = minetest.get_node(pos).param2
		local dir = minetest.facedir_to_dir(facedir)
		local piston_location = vector.add(pos,dir)
		minetest.remove_node(piston_location)
		minetest.set_node(pos,{name="redstone:piston_off",param2=facedir})
		piston_location.y = piston_location.y + 1
		minetest.punch_node(piston_location)
		minetest.sound_play("piston", {pos=pos,pitch=math.random(85,100)/100})
    end,
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local facedir = oldnode.param2
		local dir = minetest.facedir_to_dir(facedir)
		local piston_location = vector.add(pos,dir)
		minetest.remove_node(piston_location)
    end,
})

minetest.register_node("redstone:actuator", {
    description = "Redstone Piston",
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
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local facedir = oldnode.param2
		local dir = minetest.facedir_to_dir(facedir)
		dir = vector.multiply(dir,-1)
		local piston_location = vector.add(pos,dir)
		minetest.remove_node(piston_location)
    end,
})


