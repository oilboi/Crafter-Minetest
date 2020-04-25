--these are helpers to create entities
slime = {}

slime.initial_properties = {
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
	automatic_face_movement_dir = 180.0,
	automatic_face_movement_max_rotation_per_sec = 300,
	--makes_footstep_sound = true,
}

slime.hp = 10
slime.speed = 5
slime.jump_timer = 0

slime.hurt_inside_timer = 0
slime.death_animation_timer = 0
slime.dead = false

slime.mob = true
slime.hostile = true
slime.hostile_timer = 0
slime.timer = 0

slime.state = 0
slime.hunger = 200
slime.view_distance = 20

slime.punch_timer = 0
slime.punched_timer = 0


--head stuff
slime.head_mount = vector.new(0,1.2,1.9)
local path = minetest.get_modpath(minetest.get_current_modname()).."/slime"
dofile(path.."/timers.lua")
dofile(path.."/movement_code.lua")
dofile(path.."/data_handling_code.lua")
dofile(path.."/interaction_code.lua")


----------------------------------


--repel from players
slime.push = function(self)
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
slime.set_animation = function(self)
	if self.speed == 0 or vector.equals(self.direction,vector.new(0,0,0)) then
		self.object:set_animation({x=0,y=0}, 1, 0, true)
	else
		self.object:set_animation({x=5,y=15}, 1, 0, true)
		local speed = self.object:get_velocity()
		speed.y = 0
		self.object:set_animation_frame_speed(vector.distance(vector.new(0,0,0),speed)*5)
	end
end


slime.on_step = function(self, dtime)
	self.manage_death_animation(self,dtime)
	if self.death_animation_timer == 0 then
		self.look_around(self,dtime)
		self.move(self,dtime)
		self.set_animation(self)
		self.manage_punch_timer(self,dtime)
		--self.debug_nametag(self,dtime)
	end
	--fix zombie state again
	if self.dead == true and self.death_animation_timer <= 0 then
		self.on_death(self)
	end
end

minetest.register_entity("mob:slime", slime)

