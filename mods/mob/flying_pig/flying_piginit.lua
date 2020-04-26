--these are helpers to create entities
flying_pig = {}

flying_pig.initial_properties = {
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
	--makes_footstep_sound = true,
}

flying_pig.hp = 10
flying_pig.speed = 5
flying_pig.jump_timer = 0

flying_pig.death_animation_timer = 0
flying_pig.dead = false

flying_pig.mob = true
flying_pig.hostile = false
flying_pig.hostile_timer = 0
flying_pig.timer = 0

flying_pig.state = 0
flying_pig.hunger = 200
flying_pig.view_distance = 20

flying_pig.punch_timer = 0
flying_pig.punched_timer = 0


--head stuff
flying_pig.head_mount = vector.new(0,1.2,1.9)
local path = minetest.get_modpath(minetest.get_current_modname()).."/flying_pig"
dofile(path.."/timers.lua")
dofile(path.."/head_code.lua")
dofile(path.."/movement_code.lua")
dofile(path.."/data_handling_code.lua")
dofile(path.."/interaction_code.lua")


----------------------------------


--repel from players
flying_pig.push = function(self)
	local pos = self.object:getpos()
	local radius = 1
	for _,object in ipairs(minetest.get_objects_inside_radius(pos, radius)) do
		if object:is_player() or object:get_luaentity().mob == true then
			local player_pos = object:getpos()
			pos.y = 0
			player_pos.y = 0
			
			local currentvel = self.object:getvelocity()
			local vel = vector.subtract(pos, player_pos)
			vel = vector.normalize(vel)
			local distance = vector.distance(pos,player_pos)
			distance = (radius-distance)*10
			vel = vector.multiply(vel,distance)
			local acceleration = vector.new(vel.x-currentvel.x,0,vel.z-currentvel.z)
			
			
			self.object:add_velocity(acceleration)
			
			acceleration = vector.multiply(acceleration, 5)
			object:add_player_velocity(acceleration)
		end
	end
end

--sets the mob animation and speed
flying_pig.set_animation = function(self)
	if self.speed == 0 or vector.equals(self.direction,vector.new(0,0,0)) then
		self.object:set_animation({x=0,y=0}, 1, 0, true)
	else
		self.object:set_animation({x=5,y=15}, 1, 0, true)
		local speed = self.object:get_velocity()
		speed.y = 0
		self.object:set_animation_frame_speed(vector.distance(vector.new(0,0,0),speed)*5)
	end
end

--this depletes the mobs hunger
flying_pig.do_hunger = function(self,dtime)
	self.hunger = self.hunger - dtime
end

--this sets the state of the mob
flying_pig.set_state = function(self,dtime)
	self.do_hunger(self,dtime)
end

flying_pig.on_step = function(self, dtime)
	if self.dead == false and self.death_animation_timer == 0 then
		self.set_state(self,dtime)
		self.move(self,dtime)
		self.set_animation(self)
		self.look_around(self,dtime)
		self.manage_punch_timer(self,dtime)
		--self.debug_nametag(self,dtime)
	else
		self.manage_death_animation(self,dtime)
	end
	--fix zombie state again
	if self.dead == true and self.death_animation_timer <= 0 then
		self.on_death(self)
	end
end

minetest.register_entity("mob:flying_pig", flying_pig)





------------------------------------------------------------------------the head

flying_pig.head = {}
flying_pig.head.initial_properties = {
	hp_max = 1,
	physical = false,
	collide_with_objects = false,
	collisionbox = {0, 0, 0, 0, 0, 0},
	visual = "mesh",
	visual_size = {x = 1.1, y = 1.1},
	mesh = "pig_head.x",
	textures = {
		"flying_pig_head.png","flying_pig_nose.png"
	},
	is_visible = true,
	pointable = false,
	--automatic_face_movement_dir = 0.0,
	--automatic_face_movement_max_rotation_per_sec = 600,
}

--remove the head if no body
flying_pig.head.on_step = function(self, dtime)
	if self.parent == nil then
		self.object:remove()
	end
end
minetest.register_entity("mob:flying_pig_head", flying_pig.head)

