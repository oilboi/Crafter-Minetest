--class 
mobs = {}

local path = minetest.get_modpath(minetest.get_current_modname()).."/api/"
dofile(path.."movement.lua")
dofile(path.."interaction.lua")
dofile(path.."data_handling.lua")
dofile(path.."head_code.lua")
dofile(path.."animation.lua")
dofile(path.."timers.lua")

mobs.register_mob = function(def)



local mob_register = {}

------------------------------------------------
mob_register.initial_properties = {
	physical = def.physical,
	collide_with_objects = def.collide_with_objects,
	collisionbox = def.collisionbox,
	visual = def.visual,
	visual_size = def.visual_size,
	mesh = def.mesh,
	textures = def.textures,
	is_visible = def.is_visible,
	pointable = def.pointable,
	automatic_face_movement_dir = def.automatic_face_movement_dir,
	automatic_face_movement_max_rotation_per_sec = def.automatic_face_movement_max_rotation_per_sec,
	makes_footstep_sound = def.makes_footstep_sound,
}


mob_register.hp = def.hp
mob_register.max_speed = def.max_speed
mob_register.jump_timer = 0


if def.head_bone then
	mob_register.head_bone = def.head_bone
	mobs.create_head_functions(def,mob_register)
	mob_register.debug_head_pos = def.debug_head_pos
	mob_register.head_directional_offset = def.head_directional_offset
	mob_register.head_height_offset = def.head_height_offset
	mob_register.head_rotation_offset = def.head_rotation_offset
	mob_register.head_position_correction = def.head_position_correction
	mob_register.head_coord = def.head_coord
	mob_register.flip_pitch = def.flip_pitch
else
	--print("create some other functions to turn mob " .. def.mobname)
end

mob_register.hurt_inside_timer = 0
mob_register.death_animation_timer = 0
mob_register.dead = false

mob_register.mob = true
mob_register.mobname = def.mobname

mob_register.hostile = def.hostile
if def.friendly_in_daylight == true then
	mob_register.friendly_in_daylight = def.friendly_in_daylight
	mob_register.friendly_in_daylight_timer = 0
end

mob_register.hostile_cooldown = def.hostile_cooldown

mob_register.hostile_timer = 0
mob_register.timer = 0

mob_register.state = def.state

mob_register.hunger = 200

mob_register.view_distance = def.view_distance

mob_register.punch_timer = 0
mob_register.punched_timer = 0
mob_register.group_attack = def.group_attack

mob_register.death_rotation = def.death_rotation

mob_register.head_mount = def.head_mount
mob_register.rotational_correction = def.rotational_correction or 0

mob_register.hurt_sound = def.hurt_sound
mob_register.die_sound = def.die_sound

mob_register.attack_type = def.attack_type
if def.attack_type == "explode" then
	mob_register.tnt_tick_timer = 0
end
mob_register.explosion_radius = def.explosion_radius
mob_register.explosion_power = def.explosion_power
mob_register.tnt_timer = nil
mob_register.explosion_time = def.explosion_time
mob_register.explosion_blink_color = def.explosion_blink_color or "white"
mob_register.explosion_blink_timer = def.explosion_blink_timer or 0.2

mob_register.custom_function_begin = def.custom_function_begin
mob_register.custom_function = def.custom_function
mob_register.custom_function_end = def.custom_function_end

mob_register.projectile_timer_cooldown = def.projectile_timer_cooldown
mob_register.attacked_hostile = def.attacked_hostile
if not def.hostile and not def.attacked_hostile then
	mob_register.scared = false
	mob_register.scared_timer = 0
end
mob_register.attack_damage = def.attack_damage

mob_register.projectile_timer = 0
mob_register.projectile_type = def.projectile_type

mob_register.takes_fall_damage = def.takes_fall_damage or true
mob_register.make_jump_noise = def.make_jump_noise
mob_register.jump_animation = def.jump_animation
mob_register.jumping_frame = def.jumping_frame

mob_register.item_drop = def.item_drop
mob_register.item_minimum = def.item_minimum or 1
mob_register.item_max = def.item_max

mob_register.die_in_light = def.die_in_light
mob_register.die_in_light_level = def.die_in_light_level

mob_register.current_animation = 0
mob_register.hurt_color_timer = 0
mob_register.damage_color = def.damage_color or "red"
mob_register.custom_on_death = def.custom_on_death

mob_register.custom_on_activate = def.custom_on_activate

mob_register.custom_on_punch = def.custom_on_punch

mob_register.c_mob_data = def.c_mob_data

if def.pathfinds then
	--mob_register.path = {}
	mob_register.pathfinding_timer = 0
end

if def.custom_timer then
	mob_register.c_timer = 0
	mob_register.custom_timer = def.custom_timer
	mob_register.custom_timer_function = def.custom_timer_function
end

mobs.create_movement_functions(def,mob_register)
mobs.create_interaction_functions(def,mob_register)
mobs.create_data_handling_functions(def,mob_register)
mobs.create_animation_functions(def,mob_register)
mobs.create_timer_functions(def,mob_register)


mob_register.on_step = function(self, dtime,moveresult)
	if self.custom_function_begin then
		self.custom_function_begin(self,dtime)
	end
	
	--self.collision_detection(self)
	if self.fall_damage then
		self.fall_damage(self)
	end
	
	if self.dead == false and self.death_animation_timer == 0 then
		if self.do_custom_timer then
			self.do_custom_timer(self,dtime)
		end

		if self.custom_function then
			self.custom_function(self,dtime,moveresult)
		end

		--self.move(self,dtime,moveresult)
		
		--self.debug_nametag(self,dtime)

		self.manage_hurt_color_timer(self,dtime)

		if self.manage_scared_timer then
			self.manage_scared_timer(self,dtime)
		end

		if self.set_animation then
			self.set_animation(self)
		end
		
		if self.look_around then
			self.look_around(self,dtime)
		end
		
		if self.pathfinding then
			self.pathfinding(self,dtime)
		end

		if self.handle_friendly_in_daylight_timer then
			self.handle_friendly_in_daylight_timer(self,dtime)
		end

		self.manage_punch_timer(self,dtime)
	else
		self.manage_death_animation(self,dtime)
		if self.move_head then
			self.move_head(self,nil,dtime)
		end
	end

	--fix zombie state again
	if self.dead == true and self.death_animation_timer <= 0 then
		self.on_death(self)
	end
	
	if self.tnt_timer then
		self.manage_explode_timer(self,dtime)
	end
	
	if self.projectile_timer then
		self.manage_projectile_timer(self,dtime)
	end
	
	if self.custom_function_end then
		self.custom_function_end(self,dtime)
	end
end

minetest.register_entity("mob:"..def.mobname, mob_register)
------------------------------------------------

end
