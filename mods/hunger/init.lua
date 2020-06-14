local minetest,math,ItemStack = 
      minetest,math,ItemStack
local mod_storage             = minetest.get_mod_storage()
local player_hunger_data      = {} -- array to hold hunger data
local hunger_class            = {}
hunger_pointer                = {} -- allow other mods to access local data
hunger_class.data             = nil
hunger_class.drowning         = nil
hunger_class.hp               = nil
hunger_class.name             = nil
hunger_class.i_data           = nil
hunger_class.count            = nil
hunger_class.food_data        = {}
hunger_class.pairs            = pairs
hunger_class.ipairs           = ipairs
hunger_class.get_connected    = minetest.get_connected_players
hunger_class.get_group        = minetest.get_item_group

--this is the max exhaustion a player will get before their
--satiation goes down and rolls over
hunger_class.exhaustion_peak  = 512
--when satiation runs out this is when the hunger peak variable
--is used, everytime the player rolls over this their hunger ticks down
--based on what they're doing
hunger_class.hunger_peak      = 128

-- creates volitile data for the game to use
hunger_class.set_data = function(player,data)
	hunger_class.name = player:get_player_name()
	if not player_hunger_data[hunger_class.name] then
		player_hunger_data[hunger_class.name] = {}
	end

	for index,i_data in hunger_class.pairs(data) do
		player_hunger_data[hunger_class.name][index] = i_data
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

-- dynamic indexing
hunger_class.get_data = function(player,requested_data)
	hunger_class.name = player:get_player_name()
	if player_hunger_data[hunger_class.name] then
		hunger_class.i_data = {}
		hunger_class.count  = 0
		for _,i_data in hunger_class.pairs(requested_data) do
			if player_hunger_data[hunger_class.name][i_data] then
				hunger_class.i_data[i_data] = player_hunger_data[hunger_class.name][i_data]
				hunger_class.count = hunger_class.count + 1
			end
		end

		if hunger_class.count > 0 then
			return(hunger_class.i_data)
		else
			return(nil)
		end
	end
	return(nil)
end

-- removes hunger data
hunger_class.terminate = function(player)
	hunger_class.name = player:get_player_name()
	if player_hunger_data[hunger_class.name] then
		player_hunger_data[hunger_class.name] = nil
	end
end

-- loads data from mod storage
hunger_class.load_data = function(player)
	hunger_class.name = player:get_player_name()
	if mod_storage:get_int(hunger_class.name.."h_save") > 0 then
		return({
				hunger                = mod_storage:get_int(hunger_class.name.."hunger"               ),
				satiation             = mod_storage:get_int(hunger_class.name.."satiation"            ),
				exhaustion            = mod_storage:get_int(hunger_class.name.."exhaustion"           ),
				regeneration_interval = mod_storage:get_int(hunger_class.name.."regeneration_interval")
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
	if type(player) ~= "string" and player:is_player() then
		hunger_class.name = player:get_player_name()
	elseif type(player) == "string" then
		hunger_class.name = player
	end
	if player_hunger_data[hunger_class.name] then
		for index,integer in hunger_class.pairs(player_hunger_data[hunger_class.name]) do
			mod_storage:set_int(hunger_class.name..index,integer)
		end
	end

	mod_storage:set_int(hunger_class.name.."h_save", 1)

	player_hunger_data[hunger_class.name] = nil
end

-- is used for shutdowns to save all data
hunger_class.save_all = function()
	for name,data in hunger_class.pairs(player_hunger_data) do
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
	hunger_class.name = player:get_player_name()
	if not player_hunger_data[hunger_class.name] then
		player_hunger_data[hunger_class.name] = {}
	end

	for index,i_data in hunger_class.pairs(data) do
		player_hunger_data[hunger_class.name][index] = i_data
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
	hunger_class.name = player:get_player_name()
	if player_hunger_data[hunger_class.name] then
		hunger_class.i_data = {}
		hunger_class.count  = 0
		for _,i_data in hunger_class.pairs(requested_data) do
			if player_hunger_data[hunger_class.name][i_data] then
				hunger_class.i_data[i_data] = player_hunger_data[hunger_class.name][i_data]
				hunger_class.count = hunger_class.count + 1
			end
		end
		if hunger_class.count > 0 then
			return(hunger_class.i_data)
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
	hunger_class.name        = player:get_player_name()
	hunger_class.data        = hunger_class.load_data(player)

	hunger_class.set_data(player,hunger_class.data)

	hud_manager.add_hud(player,"hunger_bg",{
		hud_elem_type = "statbar",
		position      = {x = 0.5, y = 1},
		text          = "hunger_icon_bg.png",
		number        = 20,
		direction     = 1,
		size          = {x = 24, y = 24},
		offset        = {x = 24*10, y= -(48 + 24 + 39)},
	})
	hud_manager.add_hud(player,"hunger",{
		hud_elem_type = "statbar",
		position      = {x = 0.5, y = 1},
		text          = "hunger_icon.png",
		number        = hunger_class.data.hunger,
		direction     = 1,
		size          = {x = 24, y = 24},
		offset        = {x = 24*10, y= -(48 + 24 + 39)},
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


local function hunger_update()
	for _,player in hunger_class.ipairs(hunger_class.get_connected()) do
		--do not regen player's health if dead - this will be reused for 1up apples
		if player:get_hp() > 0 then
		

			hunger_class.data = hunger_class.get_data(player,{
				"hunger","satiation","exhaustion","regeneration_interval"
			})

			print(dump(hunger_class.data))

			--movement state
			local m_data = movement_pointer.get_data(player,{"state"})
			if m_data then
				m_data = m_data.state
			end
			
			-- if player is moving in state 0 add 0.5
			if m_data == 0 then
				local input = player:get_player_control()
				if input.jump or input.right or input.left or input.down or input.up then
					m_data = 0.5
				end
			end
			
			

			-- count down invisible satiation bar
			if hunger_class.data.satiation > 0 and hunger_class.data.hunger >= 20 then
				hunger_class.data.exhaustion = hunger_class.tick_up_satiation(m_data, hunger_class.data.exhaustion)
				if hunger_class.data.exhaustion >= hunger_class.exhaustion_peak then

					hunger_class.data.satiation = hunger_class.data.satiation - 1
					hunger_class.data.exhaustion = hunger_class.data.exhaustion - hunger_class.exhaustion_peak
					
					--reset this to use for the hunger tick
					if hunger_class.data.satiation == 0 then
						hunger_class.data.exhaustion = 0
					end

					hunger_class.set_data(player,{satiation=hunger_class.data.satiation})
				end
				hunger_class.set_data(player,{exhaustion=hunger_class.data.exhaustion})
			-- count down hunger bars
			elseif hunger_class.data.hunger > 0 then
				hunger_class.data.exhaustion = hunger_class.tick_up_hunger(m_data,hunger_class.data.exhaustion)
				
				if hunger_class.data.exhaustion >= hunger_class.hunger_peak then
					--don't allow hunger to go negative
					if hunger_class.data.hunger > 0 then
						hunger_class.data.exhaustion = hunger_class.data.exhaustion - hunger_class.hunger_peak
						hunger_class.data.hunger = hunger_class.data.hunger - 1
						hunger_class.set_data(player,{hunger=hunger_class.data.hunger})
					end
				end
				hunger_class.set_data(player,{exhaustion=hunger_class.data.exhaustion})
			-- hurt the player if hunger bar empty
			elseif hunger_class.data.hunger <= 0 then
				hunger_class.data.exhaustion = hunger_class.data.exhaustion + 1
				local hp = player:get_hp()
				if hp > 0 and hunger_class.data.exhaustion >= 2 then
					player:set_hp(hp-1)
					hunger_class.data.exhaustion = 0
				end
				hunger_class.set_data(player,{exhaustion=hunger_class.data.exhaustion})
			end
			
			
			hunger_class.hp = player:get_hp()
			hunger_class.drowning = drowning_pointer.get_data(player,{"drowning"}).drowning
			--make regeneration happen every second
			if hunger_class.drowning == 0 and hunger_class.data.hunger >= 20 and hunger_class.hp < 20 then --  meta:get_int("on_fire") == 0 
				--print(regeneration_interval,"--------------------------")
				hunger_class.data.regeneration_interval = hunger_class.data.regeneration_interval + 1
				if hunger_class.data.regeneration_interval >= 2 then
					player:set_hp(hunger_class.hp+1)
					hunger_class.data.exhaustion = hunger_class.data.exhaustion + 32
					hunger_class.data.regeneration_interval = 0
					
					hunger_class.set_data(player,{
						regeneration_interval = hunger_class.data.regeneration_interval,
						exhaustion            = hunger_class.data.exhaustion           ,
						satiation             = hunger_class.data.satiation            ,
					})
				else
					hunger_class.set_data(player,{regeneration_interval=hunger_class.data.regeneration_interval})
				end
			--reset the regen interval
			else
				hunger_class.set_data(player,{regeneration_interval=0})
			end
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
		hunger_class.set_data(digger,{
			exhaustion = hunger_class.get_data(digger,{"exhaustion"}).exhaustion + math.random(0,2)
		})
	end
end)

-- take the eaten food
hunger_class.take_food = function(player)
	hunger_class.data = player:get_wielded_item()
	hunger_class.data:take_item()
	player:set_wielded_item(hunger_class.data)
end

-- players eat food
hunger_pointer.eat_food = function(player,item)
	hunger_class.data = hunger_class.get_data(player,{
		"hunger"   ,
		"satiation",
	})	
	
	if type(item) == "string" then
		item = ItemStack(item)
	elseif type(item) == "table" then
		item = ItemStack(item.name)
	end
	item = item:get_name()
	
	hunger_class.food_data.satiation = hunger_class.get_group( item, "satiation" )
	hunger_class.food_data.hunger    = hunger_class.get_group( item, "hunger"    )
	
	hunger_class.data.hunger = hunger_class.data.hunger + hunger_class.food_data.hunger

	if hunger_class.data.hunger > 20 then
		hunger_class.data.hunger = 20
	end
	
	-- unlimited
	-- this makes the game easier
	hunger_class.data.satiation = hunger_class.data.satiation + hunger_class.food_data.satiation
	
	hunger_class.set_data(player,{
		hunger    = hunger_class.data.hunger   ,
		satiation = hunger_class.data.satiation,
	})

	hunger_class.take_food(player)
end

-- easily allows mods to register food
minetest.register_food = function(name,def)
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
