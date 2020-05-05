minetest.register_on_joinplayer(function(player)
	local meta = player:get_meta()
	--give players new hunger when they join
	if meta:get_int("hunger") == 0 then
		meta:set_int("hunger", 20)
		meta:set_int("satiation", 5)
	end
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
		number = 20,
		direction = 1,
		size = {x = 24, y = 24},
		offset = {x = 24*10, y= -(48 + 50 + 39)},
	})
	meta:set_int("hunger_bar", hunger_bar)
end)

local function hunger_update()
	for _,player in ipairs(minetest.get_connected_players()) do
		local meta = player:get_meta()
		local satiation = meta:get_int("satiation")
		local hunger = meta:get_int("hunger")
		local running = (meta:get_string("player.player_movement_state") == "1")
		local bunny_hopping = (meta:get_string("player.player_movement_state") == "2")
		local sneaking = (meta:get_string("player.player_movement_state") == "3")		
		local got_hungry = math.random()
		if satiation > 0 then
			if running and got_hungry > 0.95 then
				satiation = satiation - 1
			elseif bunny_hopping and got_hungry > 0.90 then
				satiation = satiation - 1
			elseif sneaking and got_hungry > 0.997 then
				satiation = satiation - 1
			elseif got_hungry > 0.998 then
				satiation = satiation - 1
			end
		end
		
		if satiation == 0 then
			if hunger > 0 then
				if running and got_hungry > 0.82 then
					hunger = hunger - 1
				elseif bunny_hopping and got_hungry > 0.77 then
					hunger = hunger - 1
				elseif sneaking and got_hungry > 0.954 then
					hunger = hunger - 1
				elseif got_hungry > 0.958 then
					hunger = hunger - 1
				end
			end
			meta:set_int("hunger", hunger)
			if hunger <= 0 then
				local hp =  player:get_hp()
				if hp > 0 then
					player:set_hp(hp-1)
				end
			end
		end
		
		local hp = player:get_hp()
		if hunger >= 20 and hp < 20 then
			player:set_hp(hp+1)
			satiation = satiation - 1
			if satiation < 0 then
				satiation = 0
			end
		end
		
		meta:set_int("satiation", satiation)
		local hunger_bar = meta:get_int("hunger_bar")
		player:hud_change(hunger_bar, "number", hunger)
	end
	
	minetest.after(1, function()
		hunger_update()
	end)
end

hunger_update()

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
	
	meta:set_int("hunger", player_hunger)
	meta:set_int("satiation", player_satiation)
end
