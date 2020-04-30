--this is where mobs are defined

--this is going to be used to set an active mob limit
global_mob_table = {}


local path = minetest.get_modpath(minetest.get_current_modname())

dofile(path.."/spawning.lua")
dofile(path.."/api/api_hook.lua")
dofile(path.."/items.lua")
dofile(path.."/chatcommands.lua")






mobs.register_mob(
    {
     mobname = "pig",
	 physical = true,
	 collide_with_objects = false,
	 collisionbox = {-0.37, -0.4, -0.37, 0.37, 0.5, 0.37},
	 visual = "mesh",
	 visual_size = {x = 3, y = 3},
	 mesh = "pig.x",
	 textures = {
	 	"body.png","leg.png","leg.png","leg.png","leg.png"
	 },
	 is_visible = true,
	 pointable = true,
	 automatic_face_movement_dir = -90.0,
	 automatic_face_movement_max_rotation_per_sec = 300,
	 makes_footstep_sound = false,
     hp = 10,
     gravity = {x = 0, y = -9.81, z = 0},
     movement_type = "walk",
     max_speed = 5,
     hostile = false,
     state = 0,
     view_distance = 15,
     
     item_drop = "mob:raw_porkchop", 
     standing_frame = {x=0,y=0},
     moving_frame = {x=5,y=15},
     animation_multiplier = 5,
     ----
      
     has_head = true, --remove this when mesh based head rotation is implemented
     head_visual = "mesh",
     head_visual_size = {x = 1.1, y = 1.1},
     head_mesh = "pig_head.x",
     head_textures ={"head.png","nose.png"},
     head_mount = vector.new(0,1.2,1.9),
     
     death_rotation = "z",
     
     hurt_sound = "pig",
     die_sound = "pig_die",
     
     attack_type = "punch",
     --explosion_radius = 4, -- how far away the mob has to be to initialize the explosion
     --explosion_power = 7, -- how big the explosion has to be
     --explosion_time = 3, -- how long it takes for a mob to explode
    }
)


mobs.register_mob(
    {
     mobname = "slime",
	 physical = true,
 	 collide_with_objects = false,
 	 collisionbox = {-0.37, -0.4, -0.37, 0.37, 0.5, 0.37},
  	 visual = "mesh",
 	 visual_size = {x = 3, y = 3},
	 mesh = "slime.x",
	 textures = {
	 	"slimecore.png","slimeeye.png","slimeeye.png","slimeeye.png","slimeoutside.png"
	 },
	 is_visible = true,
	 pointable = true,
	 automatic_face_movement_dir = 180,
	 automatic_face_movement_max_rotation_per_sec = 300,
	 makes_footstep_sound = false,
     hp = 10,
     gravity = {x = 0, y = -9.81, z = 0},
     movement_type = "jump",
     max_speed = 5,
     hostile = true,
     state = 0,
     view_distance = 20,
     item_drop = "mob:slimeball",
    
     standing_frame = {x=0,y=0},
     moving_frame = {x=0,y=0},
     animation_multiplier = 5,
     ----
     has_head = false, --remove this when mesh based head rotation is implemented
     
     death_rotation = "x",
     
     hurt_sound = "slime_die",
     die_sound = "slime_die",
     
     attack_type = "punch",
     die_in_light = true,
     die_in_light_level = 12,
    }
)


mobs.register_mob(
    {
     mobname = "flying_pig",
	 physical = true,
	 collide_with_objects = false,
	 collisionbox = {-0.37, -0.4, -0.37, 0.37, 0.5, 0.37},
	 visual = "mesh",
	 visual_size = {x = 3, y = 3},
	 mesh = "pig.x",
	 textures = {
		"flying_pig_body.png","flying_pig_leg.png","flying_pig_leg.png","flying_pig_leg.png","flying_pig_leg.png"
	},
	 is_visible = true,
	 pointable = true,
	 automatic_face_movement_dir = -90.0,
	 automatic_face_movement_max_rotation_per_sec = 300,
	 makes_footstep_sound = false,
     hp = 10,
     gravity = {x = 0, y = -1, z = 0},
     movement_type = "jump",
     max_speed = 5,
     hostile = true,
     state = 0,
     view_distance = 50,
     item_drop = "main:gold",
     item_minimum = 4,
     item_amount = 5,
      
     standing_frame = {x=0,y=0},
     moving_frame = {x=5,y=15},
     animation_multiplier = 5,
     ----
      
     has_head = true, --remove this when mesh based head rotation is implemented
     head_visual = "mesh",
     head_visual_size = {x = 1.1, y = 1.1},
     head_mesh = "pig_head.x",
     head_textures ={"flying_pig_head.png","flying_pig_nose.png"},
     head_mount = vector.new(0,1.2,1.9),
     
     death_rotation = "z",
     
     hurt_sound = "pig",
     die_sound = "pig_die",
     
     attack_type = "projectile",
     projectile_timer_cooldown = 5,
     projectile_type = "tnt:tnt",
     
     --explosion_radius = 4, -- how far away the mob has to be to initialize the explosion
     --explosion_power = 7, -- how big the explosion has to be
     --explosion_time = 3, -- how long it takes for a mob to explode
    }
)



mobs.register_mob(
    {
     mobname = "creepig",
	 physical = true,
	 collide_with_objects = false,
	 collisionbox = {-0.37, -0.4, -0.37, 0.37, 0.5, 0.37},
	 visual = "mesh",
	 visual_size = {x = 3, y = 3},
	 mesh = "pig.x",
	 textures = {
		"creepig_body.png","creepig_leg.png","creepig_leg.png","creepig_leg.png","creepig_leg.png"
	},
	 is_visible = true,
	 pointable = true,
	 automatic_face_movement_dir = -90.0,
	 automatic_face_movement_max_rotation_per_sec = 300,
	 makes_footstep_sound = false,
     hp = 10,
     gravity = {x = 0, y = -9.81, z = 0},
     movement_type = "walk",
     max_speed = 4,
     hostile = true,
     state = 0,
     view_distance = 20,
     item_drop = "mob:cooked_porkchop",
      
     standing_frame = {x=0,y=0},
     moving_frame = {x=5,y=15},
     animation_multiplier = 5,
     ----
      
     has_head = true, --remove this when mesh based head rotation is implemented
     head_visual = "mesh",
     head_visual_size = {x = 1.1, y = 1.1},
     head_mesh = "pig_head.x",
     head_textures ={"creepig_head.png","creepig_nose.png"},
     head_mount = vector.new(0,1.2,1.9),
     
     death_rotation = "z",
     
     hurt_sound = "pig",
     die_sound = "pig_die",
     
     attack_type = "explode",
     --projectile_timer_cooldown = 5,
     --projectile_type = "tnt:tnt",
     
     explosion_radius = 2, -- how far away the mob has to be to initialize the explosion
     explosion_power = 7, -- how big the explosion has to be
     explosion_time = 5, -- how long it takes for a mob to explode
     
     die_in_light = true,
     die_in_light_level = 12,
    }
)
