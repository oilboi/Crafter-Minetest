--this is where all the code is stored for the pig mob's head

--converts the degrees to radians
local degrees_to_radians = function(degrees)
	--print(d)
	return(degrees/180.0*math.pi)
end

--converts yaw to degrees
local degrees = function(yaw)
	yaw = yaw + math.pi
	return(yaw*180.0/math.pi)
end

--rounds it up to an integer
local degree_round = function(degree)
	return(degree + 0.5 - (degree + 0.5) % 1)
end
--turns radians into degrees - not redundant
--doesn't add math.pi
local radians_to_degrees = function(radians)
	return(radians*180.0/math.pi)
end


--make sure this is redefined as shown below aka
--don't run mob_rotation_degree_to_radians(rotation)
--run local radians = mob_rotation_degree_to_radians(rotation)
--or the mobs head rotation will become overwritten
local head_rotation_to_radians = function(rotation)
	return{
		x = 0, --roll should never be changed
		y = degrees_to_radians(180 - rotation.y)*-1,
		z = degrees_to_radians(90 - rotation.z)
	}
end

--this is the "eyes" of the mob
mob.raycast_look = function(self,dtime)
	if self.head_rotation and self.head_pos and self.yaw then
		--clone the memory as to not overwrite
		local head_rotation = table.copy(self.head_rotation)
		
		local radians = head_rotation_to_radians(head_rotation)
		
		--get the real rotation of the head in radians
		local real_yaw = degrees_to_radians(self.yaw+180)+radians.y
		local dir = vector.multiply(minetest.yaw_to_dir(real_yaw),2)
		
		local convert_to_pitch = minetest.yaw_to_dir(radians.z)
		dir.y = convert_to_pitch.x * math.pi/1.5
		
		
		local pos = self.head_pos
		
		local pos2 = vector.add(pos,vector.multiply(dir,self.view_distance))
		
		return(minetest.raycast(pos, pos2, false, true))
	end
end

--this makes a mob check if they're about to walk off a cliff
mob.look_below = function(self)
	if self.yaw then
		local yaw = degrees_to_radians(self.yaw+180)
		local dir = minetest.yaw_to_dir(yaw)
		local pos = self.object:get_pos()
		
		local ray_pos = vector.add(dir,pos)
		
		local pos_below = vector.new(ray_pos.x,ray_pos.y - 5,ray_pos.z)
		
		minetest.add_particle({
			pos = ray_pos,
			velocity = {x=0, y=0, z=0},
			acceleration = {x=0, y=0, z=0},
			expirationtime = 1,
			size = 1,
			collisiondetection = false,
			vertical = false,
			texture = "wood.png",
			playername = "singleplayer"
		})
		
		return(minetest.raycast(ray_pos, pos_below, false, true))
	end
end

--a movement test to move the head
mob.move_head = function(self,pos2)
	if self.child then
		--print(self.head_rotation.y)
		--if passed a direction to look
		local pos = self.object:get_pos()
		local body_yaw = self.object:get_yaw() - (math.pi/2)
		local dir = vector.multiply(minetest.yaw_to_dir(body_yaw),0.72)
		local real_dir = minetest.yaw_to_dir(body_yaw)
		local body_yaw = degree_round(degrees(minetest.dir_to_yaw(dir)))
		--save the yaw for debug
		self.yaw = body_yaw
		
		--pos is where the head actually is
		pos = vector.add(pos,dir)
		pos.y = pos.y + 0.36
		--use this to literally look around
		self.head_pos = pos
		
		
		--if the function was given a pos
		if pos2 then

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
