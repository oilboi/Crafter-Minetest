--
mobs.create_head_functions = function(def,mob_register)
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
	
	--a movement test to move the head
	mob_register.move_head = function(self,pos2,dtime)
		if self.head_bone then
			if self.head_coord == "horizontal" then
				--print(self.head_bone)
				local head_position,head_rotation = self.object:get_bone_position(self.head_bone)
				--[[ debug
				if rotation then
					--print("--------------------------------")
					--rotation.x = rotation.x + 1
					rotation.z = rotation.z + 1
					rotation.y = 0
					
					if rotation.x > 90 then
						 rotation.x = -90
					end
					if rotation.z > 90 then
						 rotation.z = -90
					end
					
					--print(rotation.x)
					self.object:set_bone_position(self.head_bone, head_position, rotation)
				end
				]]--
				
				--print(self.head_rotation.y)
				--if passed a direction to look
				local pos = self.object:get_pos()
				local body_yaw = self.object:get_yaw()
				
				if not body_yaw then
					return
				end
				
				local dir = vector.multiply(minetest.yaw_to_dir(body_yaw+self.head_rotation_offset),self.head_directional_offset)
				
				
				local body_yaw = minetest.dir_to_yaw(dir)
				
				--pos is where the head actually is
				pos = vector.add(pos,dir)
				pos.y = pos.y + self.head_height_offset
				
				--use this to literally look around
				self.head_pos = pos
				
				if self.debug_head_pos == true then
					minetest.add_particle({
						pos = pos,
						velocity = {x=0, y=0, z=0},
						acceleration = {x=0, y=0, z=0},
						expirationtime = 0.2,
						size = 1,
						texture = "dirt.png",
					})
				end
				
				--if the function was given a pos
				if pos2 then
					--compare the head yaw to the body
					
					local head_yaw = minetest.dir_to_yaw(vector.direction(pos,pos2))
					
					local goal_yaw = body_yaw-head_yaw
					
					print(goal_yaw)
					
					--if within range then do calculations
					if goal_yaw <= math.pi/2 and goal_yaw >= -math.pi/2 then
						---begin pitch calculation
						--feed a 2D coordinate flipped into dir to yaw to calculate pitch
						head_rotation.x = degrees(minetest.dir_to_yaw(vector.new(vector.distance(vector.new(pos.x,0,pos.z),vector.new(pos2.x,0,pos2.z)),0,pos.y-pos2.y))+(math.pi/2))
						head_rotation.z = degrees(-goal_yaw)
						self.object:set_bone_position(self.head_bone, head_position, head_rotation)
						return(true)
					--nothing to look at
					else--dofile(path.."movement.lua")
						self.return_head_to_origin(self,dtime)
						return(false)
					end
					
				--if nothing to look at
				else
					self.return_head_to_origin(self,dtime)
					return(false)
				end
			--[[
			elseif self.head_coord == "vertical" then
				
				--print(self.head_bone)
				local head_position,head_rotation = self.object:get_bone_position(self.head_bone)
				
				-- debug
				if head_rotation then
					print("test")
					--print("--------------------------------")
					--head_rotation.x = head_rotation.x + 1
					head_rotation.y = head_rotation.y + 1
					head_rotation.z = 0
					
					if head_rotation.x > 90 then
						 head_rotation.x = -90
					end
					if head_rotation.z > 90 then
						 head_rotation.z = -90
					end
					if head_rotation.y > 90 then
						 head_rotation.y = -90
					end
					
					--print(rotation.x)
					self.object:set_bone_position(self.head_bone, head_position, head_rotation)
				end
				
				
				--print(self.head_rotation.y)
				--if passed a direction to look
				
				local pos = self.object:get_pos()
				local body_yaw = self.object:get_yaw()
				if not body_yaw then
					return
				end
				
				local dir = vector.multiply(minetest.yaw_to_dir(body_yaw+self.head_rotation_offset),self.head_directional_offset)
				
				
				local body_yaw = minetest.dir_to_yaw(dir)
				
				--pos is where the head actually is
				pos = vector.add(pos,dir)
				pos.y = pos.y + self.head_height_offset
				
				--use this to literally look around
				self.head_pos = pos
				
				if self.debug_head_pos == true then
					minetest.add_particle({
						pos = pos,
						velocity = {x=0, y=0, z=0},
						acceleration = {x=0, y=0, z=0},
						expirationtime = 0.2,
						size = 1,
						texture = "dirt.png",
					})
				end
				
				--if the function was given a pos
				if pos2 then
					--compare the head yaw to the body
					local head_yaw = minetest.dir_to_yaw(vector.direction(pos,pos2))
					
					local goal_yaw = body_yaw-head_yaw
					
					if goal_yaw < -math.pi then
						goal_yaw = goal_yaw + math.pi
					elseif goal_yaw > math.pi then
						goal_yaw = goal_yaw - math.pi
					end
					
					print("goal_yaw="..goal_yaw,"body_yaw="..body_yaw,"head_yaw="..head_yaw)
					
					--if within range then do calculations
					if goal_yaw <= math.pi/2 and goal_yaw >= -math.pi/2 then
						---begin pitch calculation
						--feed a 2D coordinate flipped into dir to yaw to calculate pitch
						head_rotation.x = degrees(minetest.dir_to_yaw(vector.new(vector.distance(vector.new(pos.x,0,pos.z),vector.new(pos2.x,0,pos2.z)),0,pos.y-pos2.y))+(math.pi/2))
						head_rotation.y = degrees(goal_yaw)
						self.object:set_bone_position(self.head_bone, head_position, head_rotation)
						return(true)
					--nothing to look at
					else--dofile(path.."movement.lua")
						self.return_head_to_origin(self,dtime)
						return(false)
					end
					
				--if nothing to look at
				else
					self.return_head_to_origin(self,dtime)
					return(false)
				end
				]]--
			end
		end
	end
	
	
	--this sets the mob to move it's head back to pointing forwards

	mob_register.return_head_to_origin = function(self,dtime)
		local head_position,head_rotation = self.object:get_bone_position(self.head_bone)
		
		if self.head_coord == "horizontal" then	
			--make the head yaw move back
			if head_rotation.x > 0 then
				head_rotation.x = head_rotation.x - (dtime*100)
			elseif head_rotation.x < 0 then
				head_rotation.x = head_rotation.x + (dtime*100)
			end
			
			if math.abs(head_rotation.x) < (dtime*100) then
				head_rotation.x = 0
			end
			
			
			--move up down (pitch) back to center
			if head_rotation.z > 0 then
				head_rotation.z = head_rotation.z - (dtime*100)
			elseif head_rotation.z < 0 then
				head_rotation.z = head_rotation.z + (dtime*100)
			end
			
			if math.abs(head_rotation.z) < (dtime*100) then
				head_rotation.z = 0
			end
		elseif self.head_coord == "vertical" then
			--make the head yaw move back
			if head_rotation.x > 0 then
				head_rotation.x = head_rotation.x - (dtime*100)
			elseif head_rotation.x < 0 then
				head_rotation.x = head_rotation.x + (dtime*100)
			end
			
			if math.abs(head_rotation.x) < (dtime*100) then
				head_rotation.x = 0
			end
			
			
			--move up down (pitch) back to center
			if head_rotation.y > 0 then
				head_rotation.y = head_rotation.y - (dtime*100)
			elseif head_rotation.y < 0 then
				head_rotation.y = head_rotation.y + (dtime*100)
			end
			
			if math.abs(head_rotation.y) < (dtime*100) then
				head_rotation.y = 0
			end
		end
		self.object:set_bone_position(self.head_bone, head_position, head_rotation)
	end
	return(mob_register)
end
