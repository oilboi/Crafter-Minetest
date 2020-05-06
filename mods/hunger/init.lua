minetest.register_on_joinplayer(function(player)
	local meta = player:get_meta()
	player:hud_add({
		hud_elem_type = "statbar",
		position = {x = 0.5, y = 1},
		text = "hunger_icon_bg.png",
		number = 20,
		direction = 1,
		size = {x = 24, y = 24},
		offset = {x = 24*10, y= -(48 + 50 + 39)},
	})
	local hunger_bar = player:hud_add({
		hud_elem_type = "statbar",
		position = {x = 0.5, y = 1},
		text = "hunger_icon.png",
		number = meta:get_int("hunger"),
		direction = 1,
		size = {x = 24, y = 24},
		offset = {x = 24*10, y= -(48 + 50 + 39)},
	})
	meta:set_int("hunger_bar", hunger_bar)
end)


minetest.register_on_newplayer(function(player)
	local meta = player:get_meta()
	--give players new hunger when they join
	if meta:get_int("hunger") == 0 then
		meta:set_int("hunger", 20)
		meta:set_int("satiation", 5)
		meta:set_int("exhaustion_tick", 0)
	end
	
end)

minetest.register_on_respawnplayer(function(player)
	local meta = player:get_meta()
	meta:set_int("hunger", 20)
	meta:set_int("satiation", 5)
	meta:set_int("exhaustion_tick", 0)
	meta:set_int("dead", 0)
	local hunger_bar = meta:get_int("hunger_bar")
	player:hud_change(hunger_bar, "number", 20)
end)

minetest.register_on_dieplayer(function(player)
	local meta = player:get_meta()
	meta:set_int("dead", 1)
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
	
		--get the metas
		local meta = player:get_meta()
		
		--do not regen player's health if dead - this will be reused for 1up apples
		if meta:get_int("dead") == 0 then --and meta:get_int("regeneration")
		
			--internal variables
			local satiation = meta:get_int("satiation")
			local hunger = meta:get_int("hunger")
			local exhaustion_tick = meta:get_int("exhaustion_tick")
			
			--movement states
			local movement_state =  meta:get_string("player.player_movement_state")
			local running = (movement_state == "1")
			local bunny_hopping = (movement_state == "2")
			local sneaking = (movement_state == "3")
			local standing = false
			local walking = false
			
			--we must seperate these two values because I forgot to
			--write in a seperate clientside state for walking/standing
			if movement_state == "0" then
				local input = player:get_player_control()
				if input.jump or input.right or input.left or input.down or input.up then
					walking = true
				else
					standing = true
				end
			end
			
			--we count up the exhaustion of the player moving around
			--based on their states
			if satiation > 0 then
				if running then
					exhaustion_tick = exhaustion_tick + 6
				elseif bunny_hopping then
					exhaustion_tick = exhaustion_tick + 8
				elseif sneaking then
					exhaustion_tick = exhaustion_tick + 1
					
				elseif walking then
					exhaustion_tick = exhaustion_tick + 3
				elseif standing then
					exhaustion_tick = exhaustion_tick + 1
				end
				
				
				if exhaustion_tick >= exhaustion_peak then
					satiation = satiation - 1
					exhaustion_tick = exhaustion_tick - exhaustion_peak
					
					--reset this to use for the hunger tick
					if satiation == 0 then
						exhaustion_tick = 0
					end
					
					meta:set_int("satiation", satiation)
				end
				
				meta:set_int("exhaustion_tick", exhaustion_tick)
			elseif hunger > 0 then
				--this is copied again because this is for future tuning
				if running then
					exhaustion_tick = exhaustion_tick + 3
				elseif bunny_hopping then
					exhaustion_tick = exhaustion_tick + 4
				elseif sneaking then
					exhaustion_tick = exhaustion_tick + 1
				elseif walking then
					exhaustion_tick = exhaustion_tick + 2
				elseif standing then
					exhaustion_tick = exhaustion_tick + 1
				end
				if exhaustion_tick >= hunger_peak then
					--don't allow hunger to go negative
					if hunger > 0 then
						exhaustion_tick = 0
						hunger = hunger - 1
						meta:set_int("hunger", hunger)
						local hunger_bar = meta:get_int("hunger_bar")
						player:hud_change(hunger_bar, "number", hunger)
					end
				end
				meta:set_int("exhaustion_tick", exhaustion_tick)
			elseif hunger <= 0 then
				exhaustion_tick = exhaustion_tick + 1
				
				local hp =  player:get_hp()
				if hp > 0 and exhaustion_tick >= 2 then
					player:set_hp(hp-1)
					exhaustion_tick = 0
				end
				meta:set_int("exhaustion_tick", exhaustion_tick)
			end
			
			
			local hp = player:get_hp()
			--make regeneration happen every second
			if hunger >= 20 and hp < 20 and satiation > 0 then
				local regeneration_interval = meta:get_int("regeneration_interval")
				--print(regeneration_interval,"--------------------------")
				regeneration_interval = regeneration_interval + 1
				if regeneration_interval >= 2 then
					player:set_hp(hp+1)
					exhaustion_tick = exhaustion_tick + 32
					meta:set_int("exhaustion_tick", exhaustion_tick)
					meta:set_int("satiation", satiation)
					regeneration_interval = 0
				end
				meta:set_int("regeneration_interval",regeneration_interval)
			--reset the regen interval
			else
				meta:set_int("regeneration_interval",0)
			end
			
			--print("satiation:",satiation,"exhaustion_tick:",exhaustion_tick)
		end
	end
	
	minetest.after(0.5, function()
		hunger_update()
	end)
end

hunger_update()

--take away hunger and satiation randomly while mining
minetest.register_on_dignode(function(pos, oldnode, digger)
	local meta = digger:get_meta()
	local exhaustion_tick = meta:get_int("exhaustion_tick")
	exhaustion_tick = exhaustion_tick + math.random(0,2)
	meta:set_int("exhaustion_tick", exhaustion_tick)
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
	if player_satiation < 20 then
		player_satiation = player_satiation + satiation
		if player_satiation > 20 then
			player_satiation = 20
		end
	end
	
	meta:set_int("exhaustion_tick", 0)
	meta:set_int("hunger", player_hunger)
	meta:set_int("satiation", player_satiation)
	local hunger_bar = meta:get_int("hunger_bar")
	player:hud_change(hunger_bar, "number", player_hunger)
	local stack = player:get_wielded_item()
	stack:take_item()
	player:set_wielded_item(stack)
end
