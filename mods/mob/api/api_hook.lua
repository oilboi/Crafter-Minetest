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



mob_register = {}

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

mob_register.hurt_inside_timer = 0
mob_register.death_animation_timer = 0
mob_register.dead = false

mob_register.mob = true
mob_register.hostile = def.hostile

mob_register.hostile_timer = 0
mob_register.timer = 0

mob_register.state = def.state

mob_register.hunger = 200

mob_register.view_distance = def.view_distance

mob_register.punch_timer = 0
mob_register.punched_timer = 0

mob_register.death_rotation = def.death_rotation

mob_register.head_mount = def.head_mount

mob_register.hurt_sound = def.hurt_sound
mob_register.die_sound = def.die_sound

mob_register.attack_type = def.attack_type
mob_register.explosion_radius = def.explosion_radius
mob_register.explosion_power = def.explosion_power
mob_register.tnt_timer = nil
mob_register.explosion_time = def.explosion_time

mob_register.custom_function_begin = def.custom_function_begin
mob_register.custom_function_end = def.custom_function_end
mob_register.projectile_timer_cooldown = def.projectile_timer_cooldown

mob_register.projectile_timer = 0
mob_register.projectile_type = def.projectile_type


mob_register.item_drop = def.item_drop
mob_register.item_minimum = def.item_minimum or def.item_amount
mob_register.item_amount = def.item_amount

mob_register.die_in_light = def.die_in_light
mob_register.die_in_light_level = def.die_in_light_level

mob_register.mob = true

mob_register.collision_boundary = def.collision_boundary or 1


mobs.create_movement_functions(def,mob_register)
mobs.create_interaction_functions(def,mob_register)
mobs.create_data_handling_functions(def,mob_register)
mobs.create_animation_functions(def,mob_register)
mobs.create_timer_functions(def,mob_register)
--only creat internal head animation functions if has head
if def.has_head == true then
    mobs.create_head_functions(def,mob_register)
end


mob_register.on_step = function(self, dtime)
    if self.custom_function_begin then
        self.custom_function_begin(self,dtime)
    end
    
    self.collision_detection(self)
    
	if self.dead == false and self.death_animation_timer == 0 then
		self.move(self,dtime)
		self.set_animation(self)
        
        if self.look_around then
            self.look_around(self,dtime)
        end
        
		self.manage_punch_timer(self,dtime)
		--self.debug_nametag(self,dtime)
	else
		self.manage_death_animation(self,dtime)
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


if def.has_head == true then
    mob_register.head = {}
    mob_register.head.initial_properties = {
        hp_max = 1,
        physical = false,
        collide_with_objects = false,
        collisionbox = {0, 0, 0, 0, 0, 0},
        visual =  def.head_visual,
        visual_size = def.head_visual_size,
        mesh = def.head_mesh,
        textures = def.head_textures,
        is_visible = true,
        pointable = false,
        --automatic_face_movement_dir = 0.0,
        --automatic_face_movement_max_rotation_per_sec = 600,
    }

    --remove the head if no body
    mob_register.head.on_step = function(self, dtime)
        if self.parent == nil then
            self.object:remove()
        end
    end
    minetest.register_entity("mob:head"..def.mobname, mob_register.head) 
end
------------------------------------------------

end
