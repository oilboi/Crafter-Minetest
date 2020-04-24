local get_group = minetest.get_node_group
--add nodes that hurt the player into the touch hurt table
local hurt_nodes = {}
minetest.register_on_mods_loaded(function()
	for _,def in pairs(minetest.registered_nodes) do
		if get_group(def.name, "touch_hurt") > 0 then
			table.insert(hurt_nodes,def.name)
		end
	end
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
			pos.y = pos.y - 0.44
			player_surroundings_index_table[name].hurt = minetest.find_node_near(pos, 1, hurt_nodes)
				
		end
	end
	--10 times a second server tick
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
