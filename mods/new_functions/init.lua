local get_group = minetest.get_node_group
local registered_nodes
local get_node = minetest.get_node
--add nodes that hurt the player into the touch hurt table
local hurt_nodes = {}
minetest.register_on_mods_loaded(function()
	for _,def in pairs(minetest.registered_nodes) do
		if get_group(def.name, "touch_hurt") > 0 then
			table.insert(hurt_nodes,def.name)
		end
	end
	registered_nodes = minetest.registered_nodes
end)

--handle nodes around, inside, and above
local player_surroundings_index_table = {}

--add the player to the index table when they join and remove when they leave
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()	
	player_surroundings_index_table[name] = {}
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	player_surroundings_index_table[name] = nil
end)
--reset their drowning settings
--minetest.register_on_dieplayer(function(ObjectRef, reason))


--handle touching hurt
local player_pos

local c_pos

local temp_hurt
local x1
local y1
local z1

local xcompare
local ycompare
local zcompare

local c_player

local subval = vector.subtract

local abs_it = math.abs
local floor_it = math.floor

local heart

local function handle_hurt(player)
	if player:get_hp() > 0 then
		player_pos = player:get_pos()
		name = player:get_player_name()
		temp_hurt = player_surroundings_index_table[name].hurt
		if temp_hurt then
			c_pos = temp_hurt.pos
			x1 = floor_it(abs_it(player_pos.x-c_pos.x)*100)
			y1 = floor_it(abs_it(player_pos.y-c_pos.y)*100)
			z1 = floor_it(abs_it(player_pos.z-c_pos.z)*100)
			--we will assume the player cbox is equal as x=0.8,y=0.5,z=0.8
			if x1 <= 80 and z1 <= 80 and y1 <= 50 then
				heart = player:get_hp()
				player:set_hp(heart - player_surroundings_index_table[name].hurt.hurt_amount)
				return(true)
			end
		end
	end
	return(false)
end

--handle inside hurt
local c_player
local heart
local legs
local head
local hurt_more

local function handle_hurt_inside(player)
	if player:get_hp() > 0 then
		player_pos = player:get_pos()
		name = player:get_player_name()
		legs = player_surroundings_index_table[name].legs
		head = player_surroundings_index_table[name].head
		if legs and head then
			hurt_more = get_group(legs, "hurt_inside")
			if get_group(head, "hurt_inside") > hurt_more then
				hurt_more = get_group(head, "hurt_inside")
			end
			
			heart = player:get_hp()
			player:set_hp(heart - hurt_more)
			return(true)
		end
	end
	return(false)
end

--handle player suffocating inside solid node
local c_player
local heart
local legs
local head
local hurt_more
local drawy
local legs
local function handle_player_suffocation(player)
	if player:get_hp() > 0 then
		player_pos = player:get_pos()
		name = player:get_player_name()
		head = player_surroundings_index_table[name].head
		
		if head and registered_nodes[head] then
            
			drawy = registered_nodes[head].drawtype

			if drawy == "normal" then
				legs = player_surroundings_index_table[name].legs
				if not legs == "aether:portal" and not legs == "nether:portal" then
					heart = player:get_hp()
					player:set_hp(heart - 1)
					return(true)
				end
			end
		end
	end
	return(false)
end


--index specific things in area
--declare here for ultra extreme efficiency
local get_node = minetest.get_node
local pos
local node
local name
local damage_pos
local collisionbox
local a_min
local a_max
local v_add = vector.add
local v_sub = vector.subtract
local get_number = table.getn
local hurt_amount
local gotten_node
local function index_players_surroundings()
	for _,player in ipairs(minetest.get_connected_players()) do
		if player:get_hp() > 0 then
			--if not dead begin index
			name = player:get_player_name()
			pos = player:get_pos()
			
			--under player position (useful for walking on hot stuff)
			pos.y = pos.y - 0.1
			player_surroundings_index_table[name].under = get_node(pos).name
			
			--at legs position (useful for pushing a player up)
			pos.y = pos.y + 0.6
			player_surroundings_index_table[name].legs = get_node(pos).name
			
			--at camera/head position (useful for drowning/being trapped inside node)
			
			pos.y = pos.y + 0.940
			player_surroundings_index_table[name].head = get_node(pos).name
			
			handle_player_suffocation(player)
			handle_hurt_inside(player)

			--used for finding a damage node next to the player (centered at player's waist)
			pos.y = pos.y - 0.74
			a_min = v_sub(pos,1)
			a_max = v_add(pos,1)
			damage_pos = minetest.find_nodes_in_area(a_min, a_max, hurt_nodes)
			
			if get_number(damage_pos) > 0 then
				for _,found_location in ipairs(damage_pos) do
					gotten_node = get_node(found_location).name
					collisionbox = registered_nodes[gotten_node].collision_box
					hurt_amount = get_group(gotten_node, "touch_hurt")
					
					if not collisionbox then
						collisionbox = {-0.5,-0.5,-0.5,0.5,0.5,0.5}
					end
					player_surroundings_index_table[name].hurt = {pos=found_location,collisionbox=collisionbox,hurt_amount=hurt_amount}
					--stop doing damage on player if they got hurt
					if handle_hurt(player) == true then
						break
					end
				end
			else
				collisionbox = nil
				player_surroundings_index_table[name].hurt = nil
			end
				
		end
	end
	--4 times a second server tick
	minetest.after(0.25, function()
		index_players_surroundings()
	end)
end

index_players_surroundings() --begin


--completely destroy the breath bar
minetest.hud_replace_builtin("breath",{
	hud_elem_type = "statbar",
	position = {x = 0.5, y = 1},
	text = "nothing.png",
	number = 50000,
	direction = 0,
	size = {x = 24, y = 24},
	offset = {x = 25, y= -(48 + 24 + 16)},
})

minetest.register_on_joinplayer(function(player)
	player:hud_set_flags({breathbar=false})
	
	local meta = player:get_meta()
	--give players new breath when they join
	meta:set_int("breath", 10)
	local bubble_id = player:hud_add({
		hud_elem_type = "statbar",
		position = {x = 0.5, y = 1},
		text = "bubble.png",
		number = 20,
		direction = 0,
		size = {x = 24, y = 24},
		offset = {x = 24, y= -(48 + 24 + 39)},
	})
	meta:set_int("breathbar", bubble_id)
end)

--begin custom breathbar
local name
local indexer
--handle the breath bar
local function fix_breath_hack()
	for _,player in ipairs(minetest.get_connected_players()) do
		player:set_breath(50000)
		name = player:get_player_name()
		indexer = player_surroundings_index_table[name].head
		if indexer == "main:water" or indexer == "main:waterflow" then
			local meta = player:get_meta()
			local breath = meta:get_int("breath")
			local breathbar = meta:get_int("breathbar")
			breath = breath - 1
			
			if breath >= 0 then
				meta:set_int("breath", breath)
				player:hud_change(breathbar, "number", breath*2)
			end
		else --reset the bar
			local meta = player:get_meta()
			meta:set_int("breath", 10)
			local breathbar = meta:get_int("breathbar")
			player:hud_change(breathbar, "number", 20)
		end
	end
	
	minetest.after(1, function()
		fix_breath_hack()
	end)
end

fix_breath_hack()


--handle the drowning
local function drown()
	for _,player in ipairs(minetest.get_connected_players()) do
		name = player:get_player_name()
		indexer = player_surroundings_index_table[name].head
		
		local meta = player:get_meta()
		local breath = meta:get_int("breath")
		if breath == 0 and (indexer == "main:water" or indexer == "main:waterflow") then
			player:set_hp(player:get_hp()-1)
		end
	end

	minetest.after(0.5, function()
		drown()
	end)
end

drown()
