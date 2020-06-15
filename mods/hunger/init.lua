local minetest,math = minetest,math

local mod_storage = minetest.get_mod_storage()
local pool        = {}


-- loads data from mod storage
local name
local temp_pool
local load_data = function(player)
	name = player:get_player_name()
	pool[name] = {}
	temp_pool = pool[name]
	if mod_storage:get_int(name.."h_save") > 0 then
		temp_pool.hunger                = mod_storage:get_int(name.."hunger"               )
		temp_pool.satiation             = mod_storage:get_int(name.."satiation"            )
		temp_pool.exhaustion            = mod_storage:get_int(name.."exhaustion"           )
		temp_pool.regeneration_interval = mod_storage:get_int(name.."regeneration_interval")
	else
		temp_pool.hunger                = 20
		temp_pool.satiation             = 20
		temp_pool.regeneration_interval = 0
		temp_pool.exhaustion            = 0
	end
end

-- saves data to be utilized on next login
local name
local temp_pool
local save_data = function(name)
	if type(name) ~= "string" and name:is_player() then
		name = name:get_player_name()
	end
	temp_pool = pool[name]
	
	mod_storage:set_int(name.."hunger",               temp_pool.hunger               )
	mod_storage:set_int(name.."satiation",            temp_pool.satiation            )
	mod_storage:set_int(name.."exhaustion",           temp_pool.exhaustion           )
	mod_storage:set_int(name.."regeneration_interval",temp_pool.regeneration_interval)

	mod_storage:set_int(name.."h_save",1)

	pool[name] = nil
end


-- is used for shutdowns to save all data
local save_all = function()
	for name,_ in pairs(pool) do
		save_data(name)
	end
end

-- an easy translation pool
local satiation_pool = {
	[0]   = 1,
	[0.5] = 3,
	[1]   = 6,
	[2]   = 8,
	[3]   = 1
}
-- ticks up the exhaustion when counting down satiation
local tick_up_satiation = function(state,exhaustion)
	return(exhaustion + satiation_pool[state])
end

-- an easy translation pool
local hunger_pool = {
	[0]   = 1,
	[0.5] = 2,
	[1]   = 3,
	[2]   = 4,
	[3]   = 1
}
-- ticks up the exhaustion when counting down hunger
local tick_up_hunger = function(state,exhaustion)
	return(exhaustion + hunger_pool[state])
end

-- allows other mods to set hunger data
local name
get_player_hunger = function(player)
	name = player:get_player_name()
	return(20)
end


-- saves specific users data for when they relog
minetest.register_on_leaveplayer(function(player)
	save_data(player)
end)

-- save all data to mod storage on shutdown
minetest.register_on_shutdown(function()
	save_all()
end)

-- create new data for hunger per player
local name
minetest.register_on_joinplayer(function(player)
	name = player:get_player_name()
	load_data(player)
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
		number        = pool[name].hunger,
		direction     = 1,
		size          = {x = 24, y = 24},
		offset        = {x = 24*10, y= -(48 + 24 + 39)},
	})
end)

-- resets the players hunger settings to max
local name
local temp_pool
minetest.register_on_respawnplayer(function(player)
	name = player:get_player_name()
	temp_pool = pool[name]
	temp_pool.hunger                = 20
	temp_pool.satiation             = 20
	temp_pool.regeneration_interval = 0
	temp_pool.exhaustion            = 0
end)


local exhaustion_peak  = 512
local hunger_peak      = 128
local temp_pool
local state
local input
local hp
local drowning
hunger_update = function()
	for _,player in ipairs(minetest.get_connected_players()) do
		--do not regen player's health if dead - this will be reused for 1up apples
		if player:get_hp() > 0 then
			name = player:get_player_name()
			temp_pool = pool[name]

			--movement state
			state = get_player_state(player)

			-- if player is moving in state 0 add 0.5
			if state == 0 then
				input = player:get_player_control()
				if input.jump or input.right or input.left or input.down or input.up then
					state = 0.5
				end
			end
			-- count down invisible satiation bar
			if temp_pool.satiation > 0 and temp_pool.hunger >= 20 then

				temp_pool.exhaustion = tick_up_satiation(state, temp_pool.exhaustion)

				if temp_pool.exhaustion > exhaustion_peak then

					temp_pool.satiation = temp_pool.satiation - 1

					temp_pool.exhaustion = temp_pool.exhaustion - exhaustion_peak
					
					--reset this to use for the hunger tick
					if temp_pool.satiation == 0 then
						temp_pool.exhaustion = 0
					end
				end
			-- count down hunger bars
			elseif temp_pool.hunger > 0 then

				temp_pool.exhaustion = tick_up_hunger(state,temp_pool.exhaustion)
				
				if temp_pool.exhaustion >= hunger_peak then
					--don't allow hunger to go negative
					if temp_pool.hunger > 0 then

						temp_pool.exhaustion = temp_pool.exhaustion - hunger_peak

						temp_pool.hunger = temp_pool.hunger - 1

					end

					hud_manager.change_hud({
						player    =  player ,
						hud_name  = "hunger",
						element   = "number",
						data      =  temp_pool.hunger
					})
				end
				
			-- hurt the player if hunger bar empty
			elseif temp_pool.hunger <= 0 then

				temp_pool.exhaustion = temp_pool.exhaustion + 1

				hp = player:get_hp()

				if hp > 0 and temp_pool.exhaustion >= 2 then
					player:set_hp( hp - 1 )
					temp_pool.exhaustion = 0
				end				
			end
			
			
			hp = player:get_hp()

			drowning = is_player_drowning(player)		

			--make regeneration happen every second
			if drowning == 0 and temp_pool.hunger >= 20 and hp < 20 then --  meta:get_int("on_fire") == 0 

				temp_pool.regeneration_interval = temp_pool.regeneration_interval + 1

				if temp_pool.regeneration_interval >= 2 then

					player:set_hp( hp + 1 )

					temp_pool.exhaustion = temp_pool.exhaustion + 32

					temp_pool.regeneration_interval = 0

				end
			--reset the regen interval
			else
				temp_pool.regeneration_interval = 0
			end
		end
	end
	
	minetest.after(0.5, function()
		hunger_update()
	end)
end

minetest.register_on_mods_loaded(function()
	minetest.after(0.5,function()
		hunger_update()
	end)
end)

--take away hunger and satiation randomly while mining
local name
minetest.register_on_dignode(function(pos, oldnode, digger)
	if digger and digger:is_player() then
		name = digger:get_player_name()
		pool[name].exhaustion = pool[name].exhaustion + math.random(0,2)
	end
end)

-- take the eaten food
local item
local take_food = function(player)
	item = player:get_wielded_item()
	item:take_item()
	player:set_wielded_item(item)
end

-- players eat food
local name
local temp_pool
local item
local satiation
local hunger
player_eat_food = function(player,item)
	name = player:get_player_name()
	temp_pool = pool[name]
	if type(item) == "string" then
		item = ItemStack(item)
	elseif type(item) == "table" then
		item = ItemStack(item.name)
	end
	item = item:get_name()
	
	satiation = minetest.get_item_group( item, "satiation" )
	hunger    = minetest.get_item_group( item, "hunger"    )
	
	temp_pool.hunger = temp_pool.hunger + hunger

	if temp_pool.hunger > 20 then
		temp_pool.hunger = 20
	end
	
	-- unlimited
	-- this makes the game easier
	temp_pool.satiation = temp_pool.satiation + satiation
	
	take_food(player)
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
		local temp_pool = pool[name]
		temp_pool.exhaustion = 0
		temp_pool.hunger     = 1
		temp_pool.satiation  = 0
	end
})
