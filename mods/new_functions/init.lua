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
pos           = nil
name          = nil
damage_nodes  = nil
a_min         = nil
a_max         = nil
damage_amount = nil
gotten_node   = nil
tick          = nil
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

	hurt = 0
	-- find the highest damage node
	if table.getn(damage_nodes) > 0 then
		for node,_ in ipairs(damage_nodes) do
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

-- damages players 4 times a second
local name
local temp_pool
local tick
handle_touch_hurting = function(player,damage,dtime)
	name      = player:get_player_name()
	temp_pool = pool[name]
	tick      = temp_pool.touch_hurt_ticker

	tick = tick - dtime
	if  tick <= 0 then
		player:set_hp(player:get_hp()-damage)
		tick = 0.25
	end
	temp_pool.touch_hurt_ticker = tick
end



--[[
-- handles being inside a hurt node
 set_on_fire = function(player,dtime)
	if player:get_hp() <= 0 then
		return
	end
	--used for finding a damage node from the center of the player
	 pos = player:get_pos()
	 pos.y =  pos.y + (player:get_properties().collisionbox[5]/2)
	 a_min =  new(
		 pos.x-0.25,
		 pos.y-0.85,
		 pos.z-0.25
	)
	 a_max =  new(
		 pos.x+0.25,
		 pos.y+0.85,
		 pos.z+0.25
	)

	 damage_nodes =  find( a_min,  a_max, {"group:hurt_inside"})

	if  table_max( damage_nodes) > 0 then
		for _,found_location in ipairs( damage_nodes) do
			start_fire(player)
		end
	end
end

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


		pos.y = pos.y - 0.1
		temp_pool.under = minetest.get_node(pos).name

		pos.y = pos.y + 0.6
		temp_pool.legs = minetest.get_node(pos).name

		if swimming then
			pos.y = pos.y + 0.35
		else
			pos.y = pos.y + 0.940
		end
		temp_pool.head = minetest.get_node(pos).name

		--hurt_collide(player,dtime)

		--hurt_inside(player,dtime)

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
