--this is where all the code is stored for the pig mob's head

--converts the degrees to radians
local degrees_to_radians = function(degrees)
	--print(d)
	return(degrees/180.0*math.pi)
end

--converts yaw to degrees
local degrees = function(yaw)
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
--[[
pig.raycast_look = function(self,dtime)
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
pig.look_below = function(self)
	if self.yaw then
		local yaw = degrees_to_radians(self.yaw)
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
]]--
--a movement test to move the head
pig.move_head = function(self,pos2,dtime)
	if self.child then
		--print(self.head_rotation.y)
		--if passed a direction to look
		local pos = self.object:get_pos()
		local body_yaw = self.object:get_yaw()
		local dir = vector.multiply(minetest.yaw_to_dir(body_yaw),0.58)
		local body_yaw = minetest.dir_to_yaw(dir)
		--save the yaw for debug
		
		--pos is where the head actually is
		pos = vector.add(pos,dir)
		pos.y = pos.y + 0.36
		--use this to literally look around
		self.head_pos = pos
				
		--if the function was given a pos
		if pos2 then

			local pitch = 0
			--compare the head yaw to the body
			local head_yaw = minetest.dir_to_yaw(vector.direction(pos,pos2))
			local goal_yaw = body_yaw-head_yaw
			
			--if within range then do calculations
			if goal_yaw <= math.pi/2 and goal_yaw >= -math.pi/2 then
				
				local current_yaw = self.head_rotation.y
				--smoothly move head using dtime
				if current_yaw > goal_yaw then
					current_yaw = current_yaw - (dtime*5)
				elseif current_yaw < goal_yaw then
					current_yaw = current_yaw + (dtime*5)
				end
				
				--stop jittering
				if math.abs(goal_yaw - current_yaw) <= (dtime*5) then
					current_yaw = goal_yaw
				end
				
				---begin pitch calculation
				
				--feed a 2D coordinate flipped into dir to yaw to calculate pitch
				local goal_pitch = (minetest.dir_to_yaw(vector.new(vector.distance(vector.new(pos.x,0,pos.z),vector.new(pos2.x,0,pos2.z)),0,pos.y-pos2.y))+(math.pi/2))*-1
				
				local current_pitch = self.head_rotation.z
								
				--smoothly move head using dtime
				if goal_pitch > current_pitch then
					current_pitch = current_pitch + (dtime*5)
				elseif goal_pitch < current_pitch then
					current_pitch = current_pitch - (dtime*5)
				end
				
				--stop jittering
				if math.abs(goal_pitch - current_pitch) <= (dtime*5) then
					current_pitch = goal_pitch
				end
				
				--convert this into degrees for the attach code
				local deg_yaw = degrees(current_yaw)
				--this is rounded because it uses animation frames baked into the head model
				local deg_pitch = math.floor(degrees(current_pitch) + 0.5)+90


				self.child:set_attach(self.object, "", self.head_mount, vector.new(0,   deg_yaw , 0))
				self.child:set_animation({x=deg_pitch,y=deg_pitch}, 15, 0, true)	
				self.head_rotation = vector.new(0,    current_yaw,    current_pitch)
				
				return(true)
			--nothing to look at
			else
				self.return_head_to_origin(self,dtime)
				return(false)
			end
			
		--if nothing to look at
		else
			self.return_head_to_origin(self,dtime)
			return(false)
		end
	end
end


--this sets the mob to move it's head back to pointing forwards
pig.return_head_to_origin = function(self,dtime)
	local current_yaw = self.head_rotation.y
	local current_pitch = self.head_rotation.z
	
	--make the head yaw move back
	if current_yaw > 0 then
		current_yaw = current_yaw - (dtime*5)
	elseif current_yaw < 0 then
		current_yaw = current_yaw + (dtime*5)
	end
	
	--finish rotation
	if math.abs(current_yaw) <= (dtime*5) then
		current_yaw = 0
	end
	
	--move up down (pitch) back to center
	if current_pitch > 0 then
		current_pitch = current_pitch - (dtime*5)
	elseif current_pitch < 0 then
		current_pitch = current_pitch + (dtime*5)
	end
	
	--finish rotation
	if math.abs(current_pitch) <= (dtime*5) then
		current_pitch = 0
	end
	
	--convert this into degrees for the attach code
	local deg_yaw = degrees(current_yaw)
	--this is rounded because it uses animation frames baked into the head model
	local deg_pitch = math.floor(degrees(current_pitch) + 0.5)+90
	
	self.child:set_attach(self.object, "", self.head_mount, vector.new(0,   deg_yaw , 0))
	self.child:set_animation({x=deg_pitch,y=deg_pitch}, 15, 0, true)	
	self.head_rotation = vector.new(0,    current_yaw,    current_pitch)
end
