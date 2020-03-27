--this is where mobs are defined

global_mob_table = {}


local path = minetest.get_modpath(minetest.get_current_modname())

dofile(path.."/spawning.lua")
dofile(path.."/items.lua")


--these are helpers to create entities
local mob = {}
mob.initial_properties = {
	hp_max = 1,
	physical = true,
	collide_with_objects = false,
	collisionbox = {-0.37, -0.01, -0.37, 0.37, 0.865, 0.37},
	visual = "mesh",
	visual_size = {x = 3, y = 3},
	mesh = "pig.b3d",
	textures = {
		"pig.png","pig.png","pig.png","pig.png","pig.png","pig.png","pig.png","pig.png","pig.png","pig.png"
	},
	is_visible = true,
	pointable = true,
	automatic_face_movement_dir = -90.0,
	automatic_face_movement_max_rotation_per_sec = 600,
}
mob.hp = 5
mob.mob = true
mob.hostile = false
mob.timer = 0


mob.get_staticdata = function(self)
	return minetest.serialize({
		--range = self.range,
		hp = self.hp,		
	})
end
mob.on_activate = function(self, staticdata, dtime_s)
	self.object:set_armor_groups({immortal = 1})
	--self.object:set_velocity({x = math.random(-5,5), y = 5, z = math.random(-5,5)})
	self.object:set_acceleration({x = 0, y = -9.81, z = 0})
	if string.sub(staticdata, 1, string.len("return")) == "return" then
		local data = minetest.deserialize(staticdata)
		if data and type(data) == "table" then
			--self.range = data.range
			self.hp = data.hp
		end
	end
	self.object:set_animation({x=0,y=40}, 20, 0, true)
	self.object:set_hp(self.hp)
	self.direction = vector.new(math.random()*math.random(-1,1),0,math.random()*math.random(-1,1))
end
mob.on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)		
	local hurt = tool_capabilities.damage_groups.fleshy
	if not hurt then
		hurt = 1
	end
	local hp = self.object:get_hp()
	self.object:set_hp(hp-hurt)
	if hp > 1 then
		minetest.sound_play("hurt", {object=self.object, gain = 1.0, max_hear_distance = 60,pitch = math.random(80,100)/100})
	end
	self.hp = hp-hurt
end
mob.on_death = function(self, killer)
	local pos = self.object:getpos()
	pos.y = pos.y + 0.4
	minetest.sound_play("mob_die", {pos = pos, gain = 1.0})
	minetest.add_particlespawner({
		amount = 40,
		time = 0.001,
		minpos = pos,
		maxpos = pos,
		minvel = vector.new(-5,-5,-5),
		maxvel = vector.new(5,5,5),
		minacc = {x=0, y=0, z=0},
		maxacc = {x=0, y=0, z=0},
		minexptime = 1.1,
		maxexptime = 1.5,
		minsize = 1,
		maxsize = 2,
		collisiondetection = false,
		vertical = false,
		texture = "smoke.png",
	})
	local obj = minetest.add_item(pos,"mob:raw_porkchop")
end
--repel from players
mob.push = function(self)
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
			
			acceleration = vector.multiply(acceleration, -0.5)
			object:add_player_velocity(acceleration)
		end
	end
end
--This makes the mob walk at a certain speed and jump
mob.move = function(self,dtime)
	self.timer = self.timer - dtime
	if self.timer <= 0 then
		self.timer = math.random(1,3)
		self.direction = vector.new(math.random()*math.random(-1,1),0,math.random()*math.random(-1,1))
	end
	local pos1 = self.object:getpos()
	local currentvel = self.object:getvelocity()
	local goal = vector.multiply(self.direction,5)
	local acceleration = vector.new(goal.x-currentvel.x,0,goal.z-currentvel.z)
	acceleration = vector.multiply(acceleration, 0.5)
	self.object:add_velocity(acceleration)
	--try to jump
	if currentvel.y <= 0 then
		local in_front = minetest.raycast(pos1, vector.add(pos1,vector.multiply(self.direction,3)), false, false):next()
		local below = minetest.raycast(pos1, vector.add(pos1, vector.new(0,-0.02,0)), false, false):next()
		if in_front then
			in_front = minetest.registered_nodes[minetest.get_node(in_front.under).name].walkable
		end
		if below then
			below = minetest.registered_nodes[minetest.get_node(below.under).name].walkable
		end
		
		if in_front and below then
			self.object:add_velocity(vector.new(0,5,0))
		end
	end
end
--makes the mob swim
mob.swim = function(self)
	local pos = self.object:getpos()
	pos.y = pos.y + 0.7
	local node = minetest.get_node(pos).name
	local vel = self.object:getvelocity()
	local goal = 3
	local acceleration = vector.new(0,goal-vel.y,0)
	self.swimming = false
	
	if node == "main:water" or node =="main:waterflow" then
		self.swimming = true
		self.object:add_velocity(acceleration)
	end
end
--sets the mob animation and speed
mob.set_animation = function(self)
	local distance = vector.distance(vector.new(0,0,0), self.object:getvelocity())
	self.object:set_animation_frame_speed(distance*20)
end
mob.on_step = function(self, dtime)
	self.move(self,dtime)
	self.set_animation(self)
end
minetest.register_entity("mob:pig", mob)
