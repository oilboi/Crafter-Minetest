local minetest,math   = minetest,math
local api             = {} -- api class
local wield           = {} -- wield item class
local player_pool     = {} -- holds data about the players
player_pointer        = {} -- allows other mods to modify player attributes
api.registered_models = {}
api.animation_blend   = 0
api.pairs             = pairs
api.ipairs            = ipairs
api.name              = nil
api.item              = nil
api.item_string       = nil
api.object            = nil
api.object_string     = nil
api.entity            = nil
api.data_index        = nil
api.current_animation = nil
api.animations        = nil
api.opacity           = nil
api.pitch             = nil
api.control_table     = nil
api.controls          = nil
api.old_controls      = nil
api.update            = nil
api.player_data       = nil
api.state             = nil
api.mouse             = nil
api.translated        = nil
api.swimming          = nil
api.force_update      = nil
api.get_connected     = minetest.get_connected_players
-- player physical data constant
api.player = {
	visual               = "mesh"       ,
	mesh                 = "player.b3d" ,
	animation_speed      = 24           ,
	visual_size          = {x = 1, y = 1, z = 1},
	textures             = {
							"player.png"    ,
							"blank_skin.png",
						   },

	animations           = {
		stand            = { x = 5  , y = 5   },
		lay              = { x = 162, y = 162 },
		walk             = { x = 168, y = 187 },
		mine             = { x = 189, y = 198 },
		walk_mine        = { x = 200, y = 219 },
		sit              = { x = 81 , y = 160 },
		sneak            = { x = 60 , y = 60  },
		sneak_mine_stand = { x = 20 , y = 30  },
		sneak_walk       = { x = 60 , y = 80  },
		sneak_mine_walk  = { x = 40 , y = 59  },
		swim             = { x = 221, y = 241 },
		swim_still       = { x = 226, y = 226 },
		die              = { x = 242, y = 253 },

						   },

	current_animation    = "stand",
	swimming             = false,
	collisionbox         = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
	old_controls         = {},
	stepheight           = 0.6  ,
	eye_height           = 1.47 ,
	attached             = false,
	wield_item           = nil  ,
}

-- allows other mods to register models
player_pointer.register_model = function(name, def)
	models[name] = def
end

-- creates default data for players
api.create_data = function(player)
	api.name = player:get_player_name()
	if not player_pool[api.name] then
		player_pool[api.name] = {}
	end

	for key,data in api.pairs(api.player) do
		player_pool[api.name][key] = data
	end	
end

-- creates volitile data for the game to use
api.set_data = function(player,data)
	api.name = player:get_player_name()
	if not player_pool[api.name] then
		player_pool[api.name] = {}
	end

	for index,i_data in api.pairs(data) do
		player_pool[api.name][index] = i_data
	end
end

-- allows other mods to modify the player
player_pointer.set_data = function(player,data)
	api.name = player:get_player_name()
	if not player_pool[api.name] then
		player_pool[api.name] = {}
	end

	for index,i_data in api.pairs(data) do
		player_pool[api.name][index] = i_data
	end

	player:set_properties(data)
end

-- removes data
api.terminate = function(player)
	api.name = player:get_player_name()
	if player_pool[name] then
		player_pool[name] = nil
	end
end

-- indexes and returns data
api.get_data = function(player,requested_data)
	api.name = player:get_player_name()
	if player_pool[api.name] then
		local data_list = {}
		local count     = 0
		for index,i_data in api.pairs(requested_data) do
			if player_pool[api.name][i_data] then
				data_list[i_data] = player_pool[api.name][i_data]
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


-- set player wield item
api.update_wield_item = function(player)
	api.name = player:get_player_name()
	
	api.item = api.get_data(player,{"wield_item"})
	if api.item then
		api.item = api.item.item
	end

	api.item_string = player:get_wielded_item():get_name()

	if api.item or (api.item and not api.item:get_luaentity()) then
		
		api.object = minetest.add_entity(player:get_pos(),"player_api:item")

		api.entity = api.object:get_luaentity()

		if api.entity then

			api.entity:set_item(api.item_string)
			
			api.entity.wielder = api.name
			
			api.object:set_attach(player, "Right_Hand", vector.new(0,0,0), vector.new(0,0,0))
			
			api.set_data(player,{
				wield_item = api.object
			})
		end
		return
	end
	
	api.entity = api.item:get_luaentity()

	api.object_string = api.entity.itemstring

	if api.entity and api.object_string ~= api.item_string then
		api.entity.itemstring = player_wield_item
		api.entity:set_item(player_wield_item)
	end
end


-- easier way to index animation
api.get_animation = function(player)
	api.data_index = api.get_data(player,{"current_animation"})
	if api.data_index and api.data_index.current_animation then
		return(api.data_index.current_animation)
	else
		return(nil)
	end
end

-- easy way to allocate new players
api.set_all_properties = function(player)
	api.player_data = api.get_data(player,{
		"visual",
		"mesh",
		"textures",
		"collisionbox",
		"eye_height",
		"stepheight",
		"visual_size"
	})
	player:set_properties(api.player_data)
end

-- easy way to set textures
api.set_textures = function(player, textures)
	api.set_data(player,{
		texture = textures,
	})
	player:set_properties({textures = textures})
end

-- easy way for other mods to set textures
player_pointer.set_textures = function(player,textures)
	api.set_textures(player,textures)
end

-- easy way to set animation
api.set_animation = function(player, animation_name, speed, loop)
	api.current_animation = api.get_data(player,{"current_animation"})
	if api.current_animation then
		api.current_animation = api.current_animation.current_animation
	end

	if api.current_animation == animation_name then
		return
	end

	api.animations = api.get_data(player,{"animations"})
	if api.animations then
		api.animations = api.animations.animations
	end

	print(loop)

	api.animations = api.animations[animation_name]
	
	player:set_animation(api.animations, speed, 0, loop)

	api.set_data(player,{
		current_animation = animation_name
	})
end

-- allows other mods to set player animation
player_pointer.set_animation = function(player,animation_name,speed)
	api.set_animation(player,animation_name,speed)
end

-- allows mods to force update animation
player_pointer.force_update = function(player)
	api.set_data(player,{
		force_update = true
	})
end

-- force updates the player
api.create_force_update = function(player)
	api.set_data(player,{
		force_update = true
	})
end


-- toggles nametag visibility
api.show_nametag = function(player,boolean)
	if boolean then
		api.opacity = 255
	else
		api.opacity = 0
	end
	
	player:set_nametag_attributes({
		color = {
			r = 255,
			b = 255,
			a = api.opacity,
			g = 255
		}
	})
end

-- remove all player data
minetest.register_on_leaveplayer(function(player)
	api.terminate(player)
end)


-- converts yaw to degrees
api.degrees = function(yaw)
	return(yaw*180.0/math.pi)
end

-- controls head bone
api.pitch_look = function(player,sneak)
	api.state = movement_pointer.get_data(player,{"swimming"})
	if api.state then
		api.state = api.state.swimming
	end

	api.pitch = api.degrees(player:get_look_vertical()) * -1
	if api.swimming then
		api.pitch = api.pitch + 90
	elseif sneak then
		api.pitch = api.pitch + 15
	end
	player:set_bone_position("Head", vector.new(0,6.3,0), vector.new(api.pitch,0,0))
end

-- checks if the player has done anything with their keyboard/mouse
api.control_check = function(player,control_table)
	api.old_controls  = api.get_data(player,{"old_controls"})
	if api.old_controls then
		api.old_controls = api.old_controls.old_controls
	end

	api.force_update = api.get_data(player,{"force_update"})
	if api.force_update then
		api.force_update = api.force_update.force_update
	end

	if api.force_update then
		api.set_data(player,{
			old_controls = control_table,
			force_update = nil          ,
		})
		return(true)
	end

	for i,k in api.pairs(api.old_controls) do
		if control_table[i] ~= k then
			api.set_data(player,{
				old_controls = control_table
			})
			return(true)
		end
	end
	api.set_data(player,{
		old_controls = control_table
	})
	return(false)
end

-- movement to animation translations
api.translation_table = {
	["walk"] = {
		["keys"]    = { -- required keys
			up      = true,
			down    = true,
			left    = true,
			right   = true,
		},
		["states" ] = { -- states
			[false] = { -- mouse input
				[0] = {animation = "walk", speed = 24},
				[1] = {animation = "walk", speed = 36},
				[2] = {animation = "walk", speed = 42},
			},
			[true ] = {
				[0] = {animation = "walk_mine", speed = 24},
				[1] = {animation = "walk_mine", speed = 36},
				[2] = {animation = "walk_mine", speed = 42},
			}
		}
	},

	["sneak"] = {
		["keys"]    = {
			up      = true,
			down    = true,
			left    = true,
			right   = true,
		},
		["states" ] = {
			[true ] = { -- moving
				--mouse input
				[false] = {animation = "sneak_walk"     , speed = 24},
				[true ] = {animation = "sneak_mine_walk", speed = 24},
			},
			[false] = { -- moving
				--mouse input
				[false] = {animation = "sneak"           , speed = 0 },
				[true ] = {animation = "sneak_mine_stand", speed = 24},
			}
		}
	},
	
	["stand"]   = {
		[true ] = {animation = "mine" , speed = 24},
		[false] = {animation = "stand", speed = 0 },
	},

	["swim"] = {
		["keys"]    = { -- required keys
			up      = true,
			down    = true,
			left    = true,
			right   = true,
		},
		["states"]  = {
			[true ] = {animation = "swim"      , speed = 24},
			[false] = {animation = "swim_still", speed = 0 },
		}
	}
}

-- translate input and combine with state
api.control_translation = function(player,control)
	api.state = movement_pointer.get_data(player,{"state","swimming"})

	if api.state then
		api.swimming = api.state.swimming
		api.state    = api.state.state
	end

	api.mouse = (control.LMB or control.RMB)

	if api.swimming then
		for k,i in api.pairs(control) do
			if i and api.translation_table.swim.keys[k] then
				api.translated = api.translation_table.swim.states[true]
				api.set_animation(player, api.translated.animation, api.translated.speed)
				return
			end
		end
		api.translated = api.translation_table.swim.states[false]
		api.set_animation(player, api.translated.animation, api.translated.speed)
		return
	else
		if control.sneak then
			for k,i in api.pairs(control) do
				if i and api.translation_table.sneak.keys[k] then
					api.translated = api.translation_table.sneak.states[true][api.mouse]
					api.set_animation(player, api.translated.animation, api.translated.speed)
					return
				end
			end
			api.translated = api.translation_table.sneak.states[false][api.mouse]
			api.set_animation(player, api.translated.animation, api.translated.speed)
			return
		else
			for k,i in api.pairs(control) do
				if i and api.translation_table.walk.keys[k] then
					api.translated = api.translation_table.walk.states[api.mouse][api.state]
					if api.translated then
						api.set_animation(player, api.translated.animation, api.translated.speed)
						return
					end
				end
			end
		end

		api.translated = api.translation_table.stand[api.mouse]
		api.set_animation(player, api.translated.animation, api.translated.speed)
	end
end

-- translates player movement to animation
api.do_animations = function(player)
	api.control_table = player:get_player_control()
	api.update = api.control_check(player,api.control_table)
	api.pitch_look(player,api.control_table.sneak)

	if api.update and player:get_hp() > 0 then
		api.control_translation(player,api.control_table)
	elseif player:get_hp() <= 0 then
		api.set_animation(player,"die",40,false)
	end
end



-- Update appearance when the player joins
minetest.register_on_joinplayer(function(player)
	api.create_data(player)
	api.set_all_properties(player)
end)

minetest.register_on_respawnplayer(function(player)
	api.create_force_update(player)
end)

-- inject into global loop
minetest.register_globalstep(function()
	for _,player in api.ipairs(api.get_connected()) do
		api.do_animations(player)
	end
end)




minetest.register_entity("player_api:item", {
	initial_properties = {
		hp_max = 1,
		physical = true,
		collide_with_objects = false,
		collisionbox = {0, 0, 0, 0, 0, 0},
		visual = "wielditem",
		visual_size = {x = 0.21, y = 0.21},
		textures = {""},
		spritediv = {x = 1, y = 1},
		initial_sprite_basepos = {x = 0, y = 0},
		is_visible = true,
		pointable = false,
	},

	itemstring = "",

	set_item = function(self, item)
		local stack = ItemStack(item or self.itemstring)
		
		self.itemstring = stack:to_string()
		

		-- Backwards compatibility: old clients use the texture
		-- to get the type of the item
		local itemname = stack:is_known() and stack:get_name() or "unknown"

		local max_count = stack:get_stack_max()
		local count = math.min(stack:get_count(), max_count)

		local size = 0.21
		local coll_height = size * 0.75
		local def = minetest.registered_nodes[itemname]
		local glow = def and def.light_source

		local is_visible = true
		if self.itemstring == "" then
			-- item not yet known
			is_visible = false
		end

		self.object:set_properties({
			is_visible = is_visible,
			visual = "wielditem",
			textures = {itemname},
			visual_size = {x = size, y = size},
			collisionbox = {-size, -0.21, -size,
				size, coll_height, size},
			selectionbox = {-size, -size, -size, size, size, size},
			--automatic_rotate = math.pi * 0.5 * 0.2 / size,
			wield_item = self.itemstring,
			glow = glow,
		})
	end,

	on_step = function(self, dtime)
		if not self.wielder then
			self.object:remove()
		end
	end,
})