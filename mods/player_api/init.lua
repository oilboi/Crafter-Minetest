local minetest,math = minetest,math
local pool = {}

-- player physical data constant
local player_constant = {
	visual               = "mesh"       ,
	mesh                 = "player.b3d" ,
	animation_speed      = 24           ,
	visual_size          = {x = 1, y = 1, z = 1},
	textures             = {
							"player.png"    ,
							"blank_skin.png",
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

-- set player wield item
local name
local temp_pool
local item
local object
local entity
local object_string
local update_wield_item = function(player)
	name = player:get_player_name()
	temp_pool = pool[name]

	object = temp_pool.wield_item

	item = player:get_wielded_item():get_name()

	if not object or (object and not object:get_luaentity()) then
		
		object = minetest.add_entity(player:get_pos(),"player_api:item")

		entity = object:get_luaentity()

		if entity then

			entity.set_item(entity,item)
			
			entity.wielder = name
			
			object:set_attach(player, "Right_Hand", vector.new(0,0,0), vector.new(0,0,0))
			
			temp_pool.wield_item = object
		end

		return -- catch it
	end
	
	entity = object:get_luaentity()
	object_string = entity.itemstring
	
	if object_string ~= item then
		entity.itemstring = item
		entity.set_item(entity,item)
	end
end

-- easy way to allocate new players
local data
local name
local temp_pool

local set_all_properties = function(player)
	name = player:get_player_name()
	pool[name] = {}
	temp_pool = pool[name]
	data = {}

	temp_pool.visual       = player_constant.visual
	temp_pool.mesh         = player_constant.mesh
	temp_pool.textures     = player_constant.textures
	temp_pool.collisionbox = player_constant.collisionbox
	temp_pool.eye_height   = player_constant.eye_height
	temp_pool.stepheight   = player_constant.stepheight
	temp_pool.visual_size  = player_constant.visual_size

	player:set_properties(temp_pool)
end

-- easy way to set textures
local set_textures = function(player, textures)
	player:set_properties({textures = textures})
end


local animation_list = {
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
}

-- easy way to set animation
local name
local temp_pool
local current_animation

local set_animation = function(player, animation_name, speed, loop)
	name = player:get_player_name()
	temp_pool = pool[name]
	current_animation = temp_pool.animation

	if current_animation == animation_name then
		return
	end
	temp_pool.animation = animation_name
	player:set_animation(animation_list[animation_name], speed, 0, loop)
end

-- allows mods to force update animation
local name
force_update_animation = function(player)
	name = player:get_player_name()
	pool[name].force_update = true
end

-- force updates the player
local name
local create_force_update = function(player)
	name = player:get_player_name()
	pool[name].force_update = true
end


-- toggles nametag visibility
local opacity
local show_nametag = function(player,boolean)
	if boolean then
		opacity = 255
	else
		opacity = 0
	end
	
	player:set_nametag_attributes({
		color = {
			r = 255,
			b = 255,
			a = opacity,
			g = 255
		}
	})
end

-- remove all player data
local name
minetest.register_on_leaveplayer(function(player)
	name = player:get_player_name()
	pool[name] = nil
end)


-- converts yaw to degrees
local degrees = function(yaw)
	return(yaw*180.0/math.pi)
end

-- controls head bone
local state
local swimming
local pitch
local pitch_look = function(player,sneak)
	state = get_player_state(player)
	swimming = is_player_swimming(player)
	pitch = degrees(player:get_look_vertical()) * -1
	if swimming then
		pitch = pitch + 90
	elseif sneak then
		pitch = pitch + 15
	end

	player:set_bone_position("Head", vector.new(0,6.3,0), vector.new(pitch,0,0))
end

-- checks if the player has done anything with their keyboard/mouse
local name
local temp_pool
local old_control

local control_check = function(player,control_table)
	name = player:get_player_name()
	temp_pool = pool[name]

	if not temp_pool.old_controls then
		temp_pool.old_controls = control_table
		return(true)
	end

	if temp_pool.force_update then
		temp_pool.old_controls = control_table
		return(true)
	end

	for i,k in pairs(temp_pool.old_controls) do
		if control_table[i] ~= k then
			temp_pool.old_controls = control_table
			return(true)
		end
	end

	temp_pool.old_controls = control_table
	return(false)
end

-- movement to animation translations
local translation_table = {
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
local name
local temp_pool
local state
local swimming
local mouse
local translated
local control_translation = function(player,control)
	name = player:get_player_name()
	temp_pool = pool[name]

	state = get_player_state(player)
	swimming = is_player_swimming(player)

	mouse = (control.LMB or control.RMB)

	if swimming then
		for k,i in pairs(control) do
			if i and translation_table.swim.keys[k] then
				translated = translation_table.swim.states[true]
				set_animation(player, translated.animation, translated.speed)
				return
			end
		end
		translated = translation_table.swim.states[false]
		set_animation(player, translated.animation, translated.speed)
		return
	else
		if control.sneak then
			for k,i in pairs(control) do
				if i and translation_table.sneak.keys[k] then
					translated = translation_table.sneak.states[true][mouse]
					set_animation(player, translated.animation, translated.speed)
					return
				end
			end
			translated = translation_table.sneak.states[false][mouse]
			set_animation(player, translated.animation, translated.speed)
			return
		else
			for k,i in pairs(control) do
				if i and translation_table.walk.keys[k] then
					translated = translation_table.walk.states[mouse][state]
					if translated then
						set_animation(player, translated.animation, translated.speed)
						return
					end
				end
			end
		end

		translated = translation_table.stand[mouse]
		set_animation(player, translated.animation, translated.speed)
	end
end

-- translates player movement to animation
local control_table
local update
local do_animations = function(player)
	control_table = player:get_player_control()
	update = control_check(player,control_table)
	pitch_look(player,control_table.sneak)
	update_wield_item(player)
	if update and player:get_hp() > 0 then
		control_translation(player,control_table)
	elseif player:get_hp() <= 0 then
		set_animation(player,"die",40,false)
	end
end



-- Update appearance when the player joins
minetest.register_on_joinplayer(function(player)
	set_all_properties(player)
end)

minetest.register_on_respawnplayer(function(player)
	create_force_update(player)
end)

-- inject into global loop
minetest.register_globalstep(function()
	for _,player in ipairs(minetest.get_connected_players()) do
		do_animations(player)
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