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

--index specific things in area
local get_node = minetest.get_node
local pos
local node
local name
local damage_pos
local collisionbox
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
			
			--used for finding a damage node next to the player (centered at player's waist)
			pos.y = pos.y - 0.74
			damage_pos = minetest.find_node_near(pos, 1, hurt_nodes)
			if damage_pos then
				collisionbox = registered_nodes[get_node(damage_pos).name].collision_box
				if not collisionbox then
					collisionbox = {-0.5,-0.5,-0.5,0.5,0.5,0.5}
				end
				player_surroundings_index_table[name].hurt = {pos=damage_pos,collisionbox=collisionbox}
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

--[[ this is disabled for now
--handle water drowning - temp - will be moved to a custom function in a future update
local breath
local function handle_drowning()
	for _,player in ipairs(minetest.get_connected_players()) do
		if player:get_hp() > 0 then
			name = player:get_player_name()
			if get_group(player_surroundings_index_table[name].head, "drowning") > 0 then
				breath = player:get_breath()
				if breath > 0 then
					player:set_breath(breath - 1)
				end
			else
				breath = player:get_breath()
				if breath < 11 then
					player:set_breath(breath + 1)
				end
			end
		end
	end
	minetest.after(0.5, function()
		handle_drowning()
	end)
end

handle_drowning()
]]--

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

local function handle_hurt()
	c_player = minetest.get_connected_players()
	for _,player in ipairs(c_player) do
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
					player:set_hp(heart - 1)
				end
			end
		end
	end
	minetest.after(0.5, function()
		handle_hurt()
	end)
end

handle_hurt()




















