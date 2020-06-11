local minetest           = minetest
local mod_storage        = minetest.get_mod_storage()
local player_hunger_data = {} -- array to hold hunger data
local hunger_class       = {}
hunger_pointer           = {} -- allow other mods to access local data

-- creates volitile data for the game to use
hunger_class.set_data = function(player,data)
	local name = player:get_player_name()
	if not player_hunger_data[name] then
		player_hunger_data[name] = {}
	end

	for index,i_data in pairs(data) do
		player_hunger_data[name][index] = i_data
	end

	if data.hunger then
		hud_manager.change_hud({
			player    =  player ,
			hud_name  = "hunger",
			element   = "number",
			data      =  data.hunger
		})
	end
end

-- indexes hunger data and returns it
hunger_class.get_data = function(player,requested_data)
	local name = player:get_player_name()
	if player_hunger_data[name] then
		local data_list = {}
		local count     = 0
		for index,i_data in pairs(requested_data) do
			if player_hunger_data[name][i_data] then
				data_list[i_data] = player_hunger_data[name][i_data]
				count = count + 1
			end
		end
		if count > 0 then
			return(data_list)
		else
			return(nil)
		end
	end
	return(nil)
end

-- removes hunger data
hunger_class.terminate = function(player)
	local name = player:get_player_name()
	if player_hunger_data[name] then
		player_hunger_data[name] = nil
	end
end

-- loads data from mod storage
hunger_class.load_data = function(player)
	local name = player:get_player_name()
	if mod_storage:get_int(name.."h_save") > 0 then
		return({
				hunger                = mod_storage:get_int(name.."hunger"               ),
				satiation             = mod_storage:get_int(name.."satiation"            ),
				exhaustion            = mod_storage:get_int(name.."exhaustion"           ),
				regeneration_interval = mod_storage:get_int(name.."regeneration_interval")
			  })
	else
		return({
				hunger                = 20,
				satiation             = 20,
				regeneration_interval = 0,
				exhaustion            = 0
			  })
	end
end

-- saves data to be utilized on next login
hunger_class.save_data = function(player)
	local name
	if type(player) ~= "string" and player:is_player() then
		name = player:get_player_name()
	elseif type(player) == "string" then
		name = player
	end
	if player_hunger_data[name] then
		for index,integer in pairs(player_hunger_data[name]) do
			mod_storage:set_int(name..index,integer)
		end
	end

	mod_storage:set_int(name.."h_save", 1)

	player_hunger_data[name] = nil
end

-- is used for shutdowns to save all data
hunger_class.save_all = function()
	for name,data in pairs(player_hunger_data) do
		hunger_class.save_data(name)
	end
end

-- an easy translation pool
hunger_class.satiation_pool = {
	[0]   = 1,
	[0.5] = 3,
	[1]   = 6,
	[2]   = 8,
	[3]   = 1
}
-- ticks up the exhaustion when counting down satiation
hunger_class.tick_up_satiation = function(m_data,exhaustion)
	return(exhaustion + hunger_class.satiation_pool[m_data])
end

-- an easy translation pool
hunger_class.hunger_pool = {
	[0]   = 1,
	[0.5] = 2,
	[1]   = 3,
	[2]   = 4,
	[3]   = 1
}
-- ticks up the exhaustion when counting down hunger
hunger_class.tick_up_hunger = function(m_data,exhaustion)
	return(exhaustion + hunger_class.hunger_pool[m_data])
end

-- allows other mods to set hunger data
hunger_pointer.set_data = function(player,data)
	local name = player:get_player_name()
	if not player_hunger_data[name] then
		player_hunger_data[name] = {}
	end

	for index,i_data in pairs(data) do
		player_hunger_data[name][index] = i_data
	end

	if data.hunger then
		hud_manager.change_hud({
			player    =  player ,
			hud_name  = "hunger",
			element   = "number",
			data      =  data.hunger
		})
	end
end

-- allows other mods to index hunger data
hunger_pointer.get_data = function(player,requested_data)
	local name = player:get_player_name()
	if player_hunger_data[name] then
		local data_list = {}
		local count     = 0
		for index,i_data in pairs(requested_data) do
			if player_hunger_data[name][i_data] then
				data_list[i_data] = player_hunger_data[name][i_data]
				count = count + 1
			end
		end
		if count > 0 then
			return(data_list)
		else
			return(nil)
		end
	end
	return(nil)
end

-- saves specific users data for when they relog
minetest.register_on_leaveplayer(function(player)
	hunger_class.save_data(player)
	hunger_class.terminate(player)
end)

-- save all data to mod storage on shutdown
minetest.register_on_shutdown(function()
	hunger_class.save_all()
end)

-- create new data for hunger per player
minetest.register_on_joinplayer(function(player)
	local name        = player:get_player_name()
	local data        = hunger_class.load_data(player)

	hunger_class.set_data(player,data)

	hud_manager.add_hud(player,"hunger_bg",{
		hud_elem_type = "statbar",
		position      = {x = 0.5, y = 1},
		text          = "hunger_icon_bg.png",
		number        = 20,
		direction     = 1,
		size          = {x = 24, y = 24},
		offset        = {x = 24*10, y= -(48 + 50 + 39)},
	})
	hud_manager.add_hud(player,"hunger",{
		hud_elem_type = "statbar",
		position      = {x = 0.5, y = 1},
		text          = "hunger_icon.png",
		number        = data.hunger,
		direction     = 1,
		size          = {x = 24, y = 24},
		offset        = {x = 24*10, y= -(48 + 50 + 39)},
	})
end)

-- resets the players hunger settings to max
minetest.register_on_respawnplayer(function(player)
	hunger_class.set_data(player,{
		hunger                = 20,
		satiation             = 20,
		regeneration_interval = 0,
		exhaustion            = 0,
	})
end)



--this is the max exhaustion a player will get before their
--satiation goes down and rolls over
local exhaustion_peak = 384
--when satiation runs out this is when the hunger peak variable
--is used, everytime the player rolls over this their hunger ticks down
--based on what they're doing
local hunger_peak = 64


local function hunger_update()
	for _,player in ipairs(minetest.get_connected_players()) do
		--do not regen player's health if dead - this will be reused for 1up apples
		if player:get_hp() > 0 then
		
			local data = hunger_class.get_data(player,{
				"hunger","satiation","exhaustion","regeneration_interval"
			})
			
			--movement state
			local m_data = movement_pointer.get_data(player,{"state"})
			if m_data then
				m_data = m_data.state
			end
			
			--we must seperate these two values
			if m_data == 0 then
				local input = player:get_player_control()
				if input.jump or input.right or input.left or input.down or input.up then
					m_data = 0.5
				end
			end
			
			-- count up the exhaustion of the player moving around

			-- count down invisible satiation bar
			if data.satiation > 0 and data.hunger >= 20 then
				data.exhaustion = hunger_class.tick_up_satiation(m_data,data.exhaustion)
				if data.exhaustion >= exhaustion_peak then
					data.satiation = data.satiation - 1
					data.exhaustion = data.exhaustion - exhaustion_peak
					
					--reset this to use for the hunger tick
					if data.satiation == 0 then
						data.exhaustion = 0
					end
					hunger_class.set_data(player,{satiation=data.satiation})
				end
				hunger_class.set_data(player,{exhaustion=data.exhaustion})
			-- count down hunger bars
			elseif data.hunger > 0 then
				data.exhaustion = hunger_class.tick_up_hunger(m_data,data.exhaustion)
				
				if data.exhaustion >= hunger_peak then
					--don't allow hunger to go negative
					if data.hunger > 0 then
						data.exhaustion = 0
						data.hunger = data.hunger - 1
						hunger_class.set_data(player,{hunger=data.hunger})
					end
				end
				hunger_class.set_data(player,{exhaustion=data.exhaustion})
			-- hurt the player if hunger bar empty
			elseif data.hunger <= 0 then
				data.exhaustion = data.exhaustion + 1
				local hp = player:get_hp()
				if hp > 0 and data.exhaustion >= 2 then
					player:set_hp(hp-1)
					data.exhaustion = 0
				end
				hunger_class.set_data(player,{exhaustion=data.exhaustion})
			end
			
			--[[
			local hp = player:get_hp()
			--make regeneration happen every second
			if meta:get_int("drowning") == 0 and meta:get_int("on_fire") == 0 and hunger >= 20 and hp < 20 then
				local regeneration_interval = meta:get_int("regeneration_interval")
				--print(regeneration_interval,"--------------------------")
				regeneration_interval = regeneration_interval + 1
				if regeneration_interval >= 2 then
					player:set_hp(hp+1)
					exhaustion = exhaustion + 32
					meta:set_int("exhaustion", exhaustion)
					meta:set_int("satiation", satiation)
					regeneration_interval = 0
				end
				meta:set_int("regeneration_interval",regeneration_interval)
			--reset the regen interval
			else
				meta:set_int("regeneration_interval",0)
			end
			]]--
		end
	end
	
	minetest.after(0.5, function()
		hunger_update()
	end)
end

minetest.register_on_mods_loaded(function()
	minetest.after(0,function()
		hunger_update()
	end)
end)

--take away hunger and satiation randomly while mining
minetest.register_on_dignode(function(pos, oldnode, digger)
	if digger and digger:is_player() then
		local data = hunger_class.get_data(digger,{"exhaustion"})
		data.exhaustion = data.exhaustion + math.random(0,2)
		hunger_class.set_data(digger,{exhaustion=data.exhaustion})
	end
end)

--allow players to eat food
function minetest.eat_food(player,item)
	local meta = player:get_meta()
	
	local player_hunger = meta:get_int("hunger")
	local player_satiation = meta:get_int("satiation")
	
	
	if type(item) == "string" then
		item = ItemStack(item)
	elseif type(item) == "table" then
		item = ItemStack(item.name)
	end
	
	item = item:get_name()
	
	local satiation = minetest.get_item_group(item, "satiation")
	local hunger = minetest.get_item_group(item, "hunger")
	
	if player_hunger < 20 then
		player_hunger = player_hunger + hunger
		if player_hunger > 20 then
			player_hunger = 20
		end
	end
	if player_satiation < satiation then
		player_satiation =  satiation
	end
	
	meta:set_int("exhaustion", 0)
	meta:set_int("hunger", player_hunger)
	meta:set_int("satiation", player_satiation)
	local hunger_bar = meta:get_int("hunger_bar")
	player:hud_change(hunger_bar, "number", player_hunger)
	local stack = player:get_wielded_item()
	stack:take_item()
	player:set_wielded_item(stack)
end

function minetest.register_food(name,def)
	minetest.register_craftitem(":"..name, {
		description = def.description,
		inventory_image = def.texture,
		groups = {satiation=def.satiation,hunger=def.hunger},
	})

	minetest.register_node(":"..name.."node", {
		tiles = {def.texture},
		drawtype = "allfaces",
	})
end


minetest.register_chatcommand("hungry", {
	params = "<mob>",
	description = "A debug command to test food",
	privs = {server = true},
	func = function(name)
		local player = minetest.get_player_by_name(name)
		hunger_class.set_data(player,{
			exhaustion = 0,
			hunger     = 1,
			satiation  = 0
		})
	end
})
