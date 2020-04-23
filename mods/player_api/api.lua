-- Minetest 0.4 mod: player
-- See README.txt for licensing and other information.

player_api = {}

-- Player animation blending
-- Note: This is currently broken due to a bug in Irrlicht, leave at 0
local animation_blend = 0

player_api.registered_models = { }

-- Local for speed.
local models = player_api.registered_models

function player_api.register_model(name, def)
	models[name] = def
end

-- Player stats and animations
local player_model = {}
local player_textures = {}
local wielded_item = {}
local player_anim = {}
local player_sneak = {}
player_api.player_attached = {}


--modify the player's wielded item
function player_api.set_wielded_item(player)
	local name = player:get_player_name()
	
	
	--local model = models[model_name]
	if not wielded_item[name] or not wielded_item[name]:get_luaentity() then
		wielded_item[name] = nil
		--we give the player an item to hold
		local itemstring = player:get_wielded_item():get_name()
		
		local wield_item = minetest.add_entity(player:get_pos(),"player_api:item")
		if wield_item then
		
			wield_item:get_luaentity():set_item(itemstring)
			
			wield_item:get_luaentity().wielder = player:get_player_name()
			
			wield_item:set_attach(player, "Right_Hand", vector.new(0,0,0), vector.new(0,0,0))
			
			wielded_item[name] = wield_item
		end
		return
	end
	
	
	local itemstring = wielded_item[name]:get_luaentity().itemstring
	local player_wield_item = player:get_wielded_item():get_name()
	
	if itemstring ~= player_wield_item then
		wielded_item[name]:get_luaentity().itemstring = player_wield_item
		local obj = wielded_item[name]:get_luaentity():set_item(obj, player_wield_item)
	end
end



function player_api.get_animation(player)
	local name = player:get_player_name()
	return {
		model = player_model[name],
		textures = player_textures[name],
		animation = player_anim[name],
	}
end

-- Called when a player's appearance needs to be updated
function player_api.set_model(player, model_name)
	local name = player:get_player_name()
	local model = models[model_name]
	if player_model[name] == model_name then
		return
	end
	player:set_properties({
		mesh = model_name,
		textures = player_textures[name] or model.textures,
		visual = "mesh",
		visual_size = model.visual_size or {x = 1, y = 1},
		collisionbox = model.collisionbox or {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
		stepheight = model.stepheight or 0.6,
		eye_height = model.eye_height or 1.47,
	})
	player_api.set_animation(player, "stand")
	player_model[name] = model_name
end

function player_api.set_textures(player, textures)
	local name = player:get_player_name()
	local model = models[player_model[name]]
	local model_textures = model and model.textures or nil
	player_textures[name] = textures or model_textures
	player:set_properties({textures = textures or model_textures,})
end

function player_api.set_animation(player, anim_name, speed)
	local name = player:get_player_name()
	if player_anim[name] == anim_name then
		return
	end
	local model = player_model[name] and models[player_model[name]]
	if not (model and model.animations[anim_name]) then
		return
	end
	local anim = model.animations[anim_name]
	
	
	--calculate local animation
	--update player's frame speed
	
	local local_player_animation = player:get_local_animation()
	local idle_animation = {x = 0,   y = 79}
	local walk_animation = {x = 168, y = 187}
	local dig_animation =  {x = 189, y = 198}
	local walk_and_dig =   {x = 200, y = 219}
	local sneak_speed = nil
	
	if anim_name == "sneak" or anim_name == "sneak_mine_stand" or anim_name == "sneak_walk" or anim_name == "sneak_mine_walk" then
		idle_animation = model.animations.sneak
		walk_animation = model.animations.sneak_walk
		dig_animation =  model.animations.sneak_mine_stand
		walk_and_dig =   model.animations.sneak_mine_walk
		sneak_speed = 16
	end
	
	--update the external animation speed that other players see
	local sneaker_speed = speed
	if sneak_speed then
		sneaker_speed = sneak_speed
	end
	
	player:set_local_animation(
		idle_animation,--idle
		walk_animation,--walk
		dig_animation,--dig
		walk_and_dig,--walk and dig
		speed
	)
	
	player_api.set_model(player, "character.b3d")
	player_anim[name] = anim_name
	player:set_animation(anim, sneaker_speed, animation_blend)
end

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	player_model[name] = nil
	player_anim[name] = nil
	player_textures[name] = nil
end)

-- Localize for better performance.
local player_set_animation = player_api.set_animation
local player_attached = player_api.player_attached

-- Prevent knockback for attached players
local old_calculate_knockback = minetest.calculate_knockback
function minetest.calculate_knockback(player, ...)
	if player_attached[player:get_player_name()] then
		return 0
	end
	return old_calculate_knockback(player, ...)
end

-- Check each player and apply animations
minetest.register_globalstep(function()
	for _, player in pairs(minetest.get_connected_players()) do
		--update the player wielded item model
		player_api.set_wielded_item(player)
		
		local name = player:get_player_name()
		local model_name = player_model[name]
		local model = model_name and models[model_name]
		if model and not player_attached[name] then
			local controls = player:get_player_control()
			local animation_speed_mod = model.animation_speed or 30

			-- Determine if the player is sneaking, and reduce animation speed if so
			--if controls.sneak then
			--	animation_speed_mod = 0
			--end
			
			local meta = player:get_meta()
			local movement_state = meta:get_string("player.player_movement_state")

			-- Apply animations based on what the player is doing
			if player:get_hp() == 0 then
				player_set_animation(player, "lay")
			elseif movement_state == "0" then
				--walking normal
				if controls.up or controls.down or controls.left or controls.right then
					if controls.LMB or controls.RMB then
						player_set_animation(player, "walk_mine", animation_speed_mod)
					else
						player_set_animation(player, "walk", animation_speed_mod)
					end
				else
					if controls.LMB or controls.RMB then
						player_set_animation(player, "mine", animation_speed_mod)
					else
						player_set_animation(player, "stand", animation_speed_mod)
					end
				end
			elseif movement_state == "1" then
				--running
				if controls.up or controls.down or controls.left or controls.right then
					if controls.LMB or controls.RMB then
						player_set_animation(player, "walk_mine", animation_speed_mod*1.5)
					else
						player_set_animation(player, "walk", animation_speed_mod*1.5)
					end
				else
					if controls.LMB or controls.RMB then
						player_set_animation(player, "mine", animation_speed_mod*1.5)
					else
						player_set_animation(player, "stand", animation_speed_mod*1.5)
					end
				end
			elseif movement_state == "2" then
				--bunnyhopping
				if controls.up or controls.down or controls.left or controls.right then
					if controls.LMB or controls.RMB then
						player_set_animation(player, "walk_mine", animation_speed_mod*1.75)
					else
						player_set_animation(player, "walk", animation_speed_mod*1.75)
					end
				else
					if controls.LMB or controls.RMB then
						player_set_animation(player, "mine", animation_speed_mod*1.75)
					else
						player_set_animation(player, "stand", animation_speed_mod*1.75)
					end
				end
			elseif movement_state == "3" then
				--sneaking
				if controls.up or controls.down or controls.left or controls.right then
					if controls.LMB or controls.RMB then
						player_set_animation(player, "sneak_mine_walk", 30)
					else
						player_set_animation(player, "sneak_walk", 30)
					end
				else
					if controls.LMB or controls.RMB then
						player_set_animation(player, "sneak_mine_stand", 30)
					else
						player_set_animation(player, "sneak", 30)
					end
				end
			--safety catches
			elseif controls.LMB or controls.RMB then
				player_set_animation(player, "mine", animation_speed_mod)
			else
				player_set_animation(player, "sneak", animation_speed_mod)
			end
		end
	end
end)
