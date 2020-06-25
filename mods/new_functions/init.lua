local minetest,math,vector,table = minetest,math,vector,table

local pool = {}


local name
get_player_head_env = function(player)
	name = player:get_player_name()
	return(pool[name].head)
end
local name
get_player_legs_env = function(player)
	name = player:get_player_name()
	return(pool[name].legs)
end

local name
player_under_check = function(player)
	name = player:get_player_name()
	return(pool[name].under)
end

local name
player_swim_check = function(player)
	name = player:get_player_name()
	return(minetest.get_nodedef(pool[name].swim_check, "walkable") == false)
end

local name
player_swim_under_check = function(player)
	name = player:get_player_name()
	return(minetest.get_nodedef(pool[name].under, "walkable") == false)
end

-- create blank list for player environment data
local name
local temp_pool
minetest.register_on_joinplayer(function(player)
	name = player:get_player_name()
	pool[name] = {}
	temp_pool = pool[name]

	temp_pool.under  = ""
	temp_pool.legs   = ""
	temp_pool.head   = ""
	temp_pool.swim_check = ""
	temp_pool.touch_hurt_ticker  = 0
	temp_pool.hurt_inside_ticker = 0
end)

-- destroy player environment data
local name
minetest.register_on_leaveplayer(function(player)
	name = player:get_player_name()
	pool[name] = nil
end)



-- handle damage when touching node
-- this is lua collision detection
-- damages players 4 times a second
local name
local temp_pool
local tick
local handle_touch_hurting = function(player,damage,dtime)
	name      = player:get_player_name()
	temp_pool = pool[name]
	tick      = temp_pool.touch_hurt_ticker

	tick = tick - dtime
	if tick <= 0 then
		player:set_hp(player:get_hp()-damage)
		tick = 0.25
	end
	temp_pool.touch_hurt_ticker = tick
end


local pos
local hurt
local name
local damage_nodes
local real_nodes
local a_min
local a_max
local damage_amount
local gotten_node
local _
local hurt_collide = function(player,dtime)
	name = player:get_player_name()
	if player:get_hp() <= 0 then
		return
	end
	-- used for finding a damage node from the center of the player
	-- rudementary collision detection
	pos = player:get_pos()
	pos.y = pos.y + (player:get_properties().collisionbox[5]/2)
	a_min = vector.new(
		pos.x-0.25,
		pos.y-0.9,
		pos.z-0.25
	)
	a_max = vector.new(
		pos.x+0.25,
		pos.y+0.9,
		pos.z+0.25
	)

	_,damage_nodes = minetest.find_nodes_in_area( a_min,  a_max, {"group:touch_hurt"})
	real_nodes = {}
	for node_data,is_next_to in pairs(damage_nodes) do
		if damage_nodes[node_data] > 0 then
			table.insert(real_nodes,node_data)
		end
	end
	hurt = 0
	-- find the highest damage node
	if table.getn(real_nodes) > 0 then
		for _,node in ipairs(real_nodes) do
			damage_amount = minetest.get_item_group(node, "touch_hurt")
			if damage_amount >  hurt then
				hurt = damage_amount
			end
		end
		handle_touch_hurting(player,damage_amount,dtime)
	else
		pool[name].touch_hurt_ticker = 0
	end
end



-- handle damage when inside node
-- this is lua collision detection

-- damages players 4 times a second
local name
local temp_pool
local tick
local handle_hurt_inside = function(player,damage,dtime)
	name      = player:get_player_name()
	temp_pool = pool[name]
	tick      = temp_pool.hurt_inside_ticker

	tick = tick - dtime
	if tick <= 0 then
		player:set_hp(player:get_hp()-damage)
		tick = 0.25
	end
	temp_pool.hurt_inside_ticker = tick
end

local pos
local hurt
local name
local damage_nodes
local real_nodes
local a_min
local a_max
local damage_amount
local gotten_node
local _
local hurt_inside = function(player,dtime)
	name = player:get_player_name()
	if player:get_hp() <= 0 then
		return
	end
	-- used for finding a damage node from the center of the player
	-- rudementary collision detection
	pos = player:get_pos()
	pos.y = pos.y + (player:get_properties().collisionbox[5]/2)
	a_min = vector.new(
		pos.x-0.25,
		pos.y-0.85,
		pos.z-0.25
	)
	a_max = vector.new(
		pos.x+0.25,
		pos.y+0.85,
		pos.z+0.25
	)

	_,damage_nodes = minetest.find_nodes_in_area( a_min,  a_max, {"group:hurt_inside"})
	real_nodes = {}
	for node_data,is_next_to in pairs(damage_nodes) do
		if damage_nodes[node_data] > 0 then
			table.insert(real_nodes,node_data)
		end
	end
	hurt = 0
	-- find the highest damage node
	if table.getn(real_nodes) > 0 then
		for _,node in ipairs(real_nodes) do
			damage_amount = minetest.get_item_group(node, "hurt_inside")
			if damage_amount >  hurt then
				hurt = damage_amount
			end
		end
		handle_hurt_inside(player,damage_amount,dtime)
	else
		pool[name].hurt_inside_ticker = 0
	end
end




-- this handles lighting a player on fire
local pos
local name
local damage_nodes
local real_nodes
local a_min
local a_max
local _
local light
local head_pos
local start_fire = function(player)
	name = player:get_player_name()
	if player:get_hp() <= 0 then
		return
	end

	pos = player:get_pos()
	
	if weather_type == 2 then
		head_pos = table.copy(pos)
		head_pos.y = head_pos.y + player:get_properties().collisionbox[5]
		light = minetest.get_node_light(head_pos, 0.5)
		if light and light == 15 then
			return
		end
	end

	-- used for finding a damage node from the center of the player
	-- rudementary collision detection
	pos.y = pos.y + (player:get_properties().collisionbox[5]/2)
	a_min = vector.new(
		pos.x-0.25,
		pos.y-0.85,
		pos.z-0.25
	)
	a_max = vector.new(
		pos.x+0.25,
		pos.y+0.85,
		pos.z+0.25
	)

	_,damage_nodes = minetest.find_nodes_in_area( a_min,  a_max, {"group:fire"})
	real_nodes = {}
	for node_data,is_next_to in pairs(damage_nodes) do
		if damage_nodes[node_data] > 0 then
			table.insert(real_nodes,node_data)
		end
	end
		
	if table.getn(real_nodes) > 0 then
		start_fire(player)
	end
end

-- this handles extinguishing a fire
local pos
local name
local relief_nodes
local real_nodes
local a_min
local a_max
local _
local light
local head_pos
local extinguish = function(player)
	name = player:get_player_name()
	if player:get_hp() <= 0 then
		return
	end
	pos = player:get_pos()
	if weather_type == 2 then
		head_pos = table.copy(pos)
		head_pos.y = head_pos.y + player:get_properties().collisionbox[5]
		light = minetest.get_node_light(head_pos, 0.5)
		if light and light == 15 then
			put_fire_out(player)
			return
		end
	end
	-- used for finding a damage node from the center of the player
	-- rudementary collision detection
	pos.y = pos.y + (player:get_properties().collisionbox[5]/2)
	a_min = vector.new(
		pos.x-0.25,
		pos.y-0.85,
		pos.z-0.25
	)
	a_max = vector.new(
		pos.x+0.25,
		pos.y+0.85,
		pos.z+0.25
	)

	_,relief_nodes = minetest.find_nodes_in_area( a_min,  a_max, {"group:extinguish"})
	real_nodes = {}
	for node_data,is_next_to in pairs(relief_nodes) do
		if relief_nodes[node_data] > 0 then
			table.insert(real_nodes,node_data)
		end
	end
		
	if table.getn(real_nodes) > 0 then
		put_fire_out(player)
	end
end
--[[
-- handle player suffocating inside solid node
environment_class.handle_player_suffocation = function(player,dtime)
	if player:get_hp() <= 0 then
		return
	end
	
	local data = environment_class.get_data(player,{"head"})

	if data then
		data = data.head
		if minetest.get_nodedef(data, "drawtype") == "normal" then
			environment_class.handle_suffocation_hurt(player,1,dtime)
		else
			environment_class.set_data(player,{suffocation_ticker = 0})
		end
	end		
end

-- damages players 4 times a second
environment_class.handle_suffocation_hurt = function(player,damage,dtime)
	environment_class.tick = environment_class.get_data(player,{"suffocation_ticker"})
	if environment_class.tick then
		environment_class.tick = environment_class.tick.suffocation_ticker
	end
	if not environment_class.tick then
		environment_class.set_data(player,{suffocation_ticker = 0.25})
		player:set_hp(player:get_hp()-damage)
	else
		environment_class.tick = environment_class.tick - dtime
		if environment_class.tick <= 0 then
			player:set_hp(player:get_hp()-damage)
			environment_class.set_data(player,{suffocation_ticker = 0.25})
		else
			environment_class.set_data(player,{suffocation_ticker = environment_class.tick})
		end
	end
end

]]--

-- environment indexing

-- creates data at specific points of the player
local name
local temp_pool
local pos
local swimming
local index_players_surroundings = function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		
		name = player:get_player_name()
		temp_pool = pool[name]

		pos = player:get_pos()
		swimming = is_player_swimming(player)

		if swimming then
			--this is where the legs would be
			temp_pool.under = minetest.get_node(pos).name

			--legs and head are in the same position
			pos.y = pos.y + 1.35
			temp_pool.legs = minetest.get_node(pos).name
			temp_pool.head = minetest.get_node(pos).name

			pos.y = pos.y + 0.7
			temp_pool.swim_check = minetest.get_node(pos).name
		else
			pos.y = pos.y - 0.1
			temp_pool.under = minetest.get_node(pos).name

			pos.y = pos.y + 0.6
			temp_pool.legs = minetest.get_node(pos).name
			
			pos.y = pos.y + 0.940
			temp_pool.head = minetest.get_node(pos).name
		end

		hurt_collide(player,dtime)

		hurt_inside(player,dtime)

		start_fire(player)

		if is_player_on_fire(player) then
			extinguish(player)
		end
		--handle_player_suffocation(player,dtime)
	end
end

-- insert all indexing data into main loop
minetest.register_globalstep(function(dtime)
	index_players_surroundings(dtime)
end)

-- a custom helper function
minetest.get_nodedef = function(nodename, fieldname)
	if not minetest.registered_nodes[nodename] then
		return nil
	end
	return minetest.registered_nodes[nodename][fieldname]
end

-- a custom helper function
minetest.get_itemdef = function(itemname, fieldname)
	if not minetest.registered_items[itemname] then
		return nil
	end
	return minetest.registered_items[itemname][fieldname]
end
