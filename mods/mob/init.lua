--this is where mobs are defined

--this is going to be used to set an active mob limit
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
	collisionbox = {-0.37, -0.37, -0.37, 0.37, 0.865, 0.37},
	visual = "mesh",
	visual_size = {x = 3, y = 3},
	mesh = "pig.x",
	textures = {
		"body.png","leg.png","leg.png","leg.png","leg.png"
	},
	is_visible = true,
	pointable = true,
	automatic_face_movement_dir = 0.0,
	automatic_face_movement_max_rotation_per_sec = 600,
}
mob.hp = 5
mob.mob = true
mob.hostile = false
mob.timer = 0
mob.state = 0
mob.hunger = 200


mob.get_staticdata = function(self)
	return minetest.serialize({
		--range = self.range,
		hp = self.hp,
		hunger = self.hunger,	
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
			self.hunger = data.hunger
		end
	end
	self.object:set_animation({x=5,y=15}, 1, 0, true)
	self.object:set_hp(self.hp)
	self.direction = vector.new(math.random()*math.random(-1,1),0,math.random()*math.random(-1,1))
	
	--set the head up
	local head = minetest.add_entity(self.object:get_pos(), "mob:head")
	if head then
		self.child = head
		self.child:get_luaentity().parent = self.object
		self.child:set_attach(self.object, "", vector.new(2.4,1.2,0), vector.new(180,0,180))
		self.head_rotation = vector.new(180,180,90)
		self.child:set_animation({x=90,y=90}, 15, 0, true)
	end
	
	--self.object:set_yaw(math.pi*math.random(-1,1)*math.random())
end


----------------------------------


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
	self.child:get_luaentity().parent = nil
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
			
			acceleration = vector.multiply(acceleration, 5)
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
		--local yaw = self.object:get_yaw() + dtime
		
		--self.object:set_yaw(yaw)
	end
	
	local pos1 = self.object:getpos()
	pos1.y = pos1.y + 0.37
	local currentvel = self.object:getvelocity()
	local goal = vector.multiply(self.direction,5)
	local acceleration = vector.new(goal.x-currentvel.x,0,goal.z-currentvel.z)
	acceleration = vector.multiply(acceleration, 0.05)
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
	self.object:set_animation_frame_speed(distance*3)
end

--converts yaw to degrees
local degrees = function(yaw)
	yaw = yaw + math.pi
	return(yaw*180.0/math.pi)
end

local degree_round = function(degree)
	return(degree + 0.5 - (degree + 0.5) % 1)
end

local radians_to_degrees = function(radians)
	return(radians*180.0/math.pi)
end

--a movement test to move the head
mob.move_head = function(self,pos2)
	if self.child then
		--print(self.head_rotation.y)
		--if passed a direction to look
		if pos2 then
			local pos = self.object:get_pos()
			local body_yaw = self.object:get_yaw() - (math.pi/2)
			local dir = vector.multiply(minetest.yaw_to_dir(body_yaw),0.72)
			local real_dir = minetest.yaw_to_dir(body_yaw)
			local body_yaw = degree_round(degrees(minetest.dir_to_yaw(dir)))
			
			--pos is where the head actually is
			pos = vector.add(pos,dir)
			pos.y = pos.y + 0.36
					
			
			local head_yaw  = degree_round(degrees(minetest.dir_to_yaw(vector.direction(pos,pos2))))			
			
			local new_yaw = (body_yaw-head_yaw)

			local pitch = 0	
			local roll = 0
			
			--print(self.head_rotation.y)
			if math.abs(new_yaw) <= 90 or math.abs(new_yaw) >= 270 then
				--do other calculations on pitch and roll
				
				local triangle = vector.new(vector.distance(pos,pos2),0,pos2.y-pos.y)
				
				local tri_yaw = minetest.dir_to_yaw(triangle)+(math.pi/2)
				
				pitch = radians_to_degrees(tri_yaw)
				
				pitch = math.floor(pitch+90 + 0.5)
				
				
				local goal_yaw = 180-new_yaw
				
				if goal_yaw < 0 then
					goal_yaw = goal_yaw + 360
				end
				
				if goal_yaw > 360 then
					goal_yaw = goal_yaw - 360
				end
				
				local current_yaw = self.head_rotation.y
				
				if goal_yaw > current_yaw then
					current_yaw = current_yaw + 4
				elseif goal_yaw < current_yaw then
					current_yaw = current_yaw - 4
				end
				
				--print(current_yaw)
				
				--stop jittering
				if math.abs(math.abs(goal_yaw) - math.abs(current_yaw)) <= 4 then
					--print("skipping:")
					--print(math.abs(goal_yaw) - math.abs(current_yaw))
					current_yaw = goal_yaw
				else
					--print(" NOT SKIPPING")
					--print(math.abs(goal_yaw) - math.abs(current_yaw))
				end
				
				
				local goal_pitch = pitch
				
				local current_pitch = self.head_rotation.z
				
				if goal_pitch > current_pitch then
					current_pitch = current_pitch + 1
				elseif goal_pitch < current_pitch then
					current_pitch = current_pitch - 1
				end
				
				self.child:set_attach(self.object, "", vector.new(2.4,1.2,0), vector.new(180,    current_yaw,    180))
				self.child:set_animation({x=current_pitch,y=current_pitch}, 15, 0, true)	
				self.head_rotation = vector.new(180,    current_yaw,    current_pitch)
			--nothing to look at
			else
				self.return_head_to_origin(self)
			end
			--                                                                      roll        newyaw      pitch
			
		--if nothing to look at
		else
			--print("not looking")
			self.return_head_to_origin(self)
		end
	end
end
--this sets the mob to move it's head back to pointing forwards
mob.return_head_to_origin = function(self)
	--print("setting back to origin")
	local rotation = self.head_rotation
	
	--make the head yaw move back twice as fast 
	if rotation.y > 180 then
		if rotation.y > 360 then
			rotation.y = rotation.y - 360
		end
		rotation.y = rotation.y - 2
	elseif rotation.y < 180 then
		if rotation.y < 0 then
			rotation.y = rotation.y + 360
		end
		rotation.y = rotation.y + 2
	end
	--finish rotation
	if math.abs(rotation.y)+1 == 180 then
		rotation.y = 180
	end
	--move up down (pitch) back to center
	if rotation.z > 90 then
		rotation.z = rotation.z - 1
	elseif rotation.z < 90 then
		rotation.z = rotation.z + 1
	end
	
	
	rotation.z = math.floor(rotation.z + 0.5)
	rotation.y = math.floor(rotation.y + 0.5)
	--print(rotation.y)
	self.child:set_attach(self.object, "", vector.new(2.4,1.2,0), vector.new(180,    rotation.y,    180))
	self.child:set_animation({x=rotation.z,y=rotation.z}, 15, 0, true)
	self.head_rotation = rotation
end

mob.look_around = function(self)
	local pos = self.object:get_pos()
	--STARE O_O
	local player_found = false
	for _,object in ipairs(minetest.get_objects_inside_radius(pos, 6)) do
		if object:is_player() and player_found == false then
			--print("test")
			player_found = true
			--look at player's camera
			local pos2 = object:get_pos()
			pos2.y = pos2.y + 1.625
			self.move_head(self,pos2)
		end
	end
	--stare straight if not found
	if player_found == false then
		self.move_head(self,nil)
	end
end
--this is the info on the mob
mob.debug_nametag = function(self,dtime)
	--we're doing this to the child because the nametage breaks the
	--animation on the mob's body
	if self.child then
		local text= "Hunger: "..self.hunger.."\n"..
					"Yaw "..self.object:get_yaw().."\n"
		self.child:set_nametag_attributes({
		color = "white",
		text = text	
		})
	end
end

--this depletes the mobs hunger
mob.do_hunger = function(self,dtime)
	self.hunger = self.hunger - dtime

end

--this sets the state of the mob
mob.set_state = function(self,dtime)
	self.do_hunger(self,dtime)
end

mob.on_step = function(self, dtime)
	self.set_state(self,dtime)
	self.move(self,dtime)
	self.set_animation(self)
	self.look_around(self)
	mob.debug_nametag(self,dtime)
end

minetest.register_entity("mob:pig", mob)





------------------------------------------------------------------------the head

local head = {}
head.initial_properties = {
	hp_max = 1,
	physical = false,
	collide_with_objects = false,
	collisionbox = {0, 0, 0, 0, 0, 0},
	visual = "mesh",
	visual_size = {x = 1.1, y = 1.1},
	mesh = "pig_head.x",
	textures = {
		"head.png","nose.png"
	},
	is_visible = true,
	pointable = false,
	--automatic_face_movement_dir = 0.0,
	--automatic_face_movement_max_rotation_per_sec = 600,
}

--remove the head if no body
head.on_step = function(self, dtime)
	if self.parent == nil then
		self.object:remove()
	end
end
minetest.register_entity("mob:head", head)
