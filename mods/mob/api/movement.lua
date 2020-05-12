--
mobs.create_movement_functions = function(def,mob_register)
	--makes the mob swim
	mob_register.swim = function(self,dtime)
		local pos = self.object:getpos()
		pos.y = pos.y + 0.3
		local node = minetest.get_node(pos).name
		self.swimming = false
		if node == "main:water" or node =="main:waterflow" then
			local vel = self.object:getvelocity()
			local goal = 3
			local acceleration = vector.new(0,goal-vel.y,0)
			--jump out of the water
			if (vel.x == 0 and self.direction.x ~= 0) or (vel.z == 0 and self.direction.z ~= 0) then
				self.object:set_velocity(vector.new(vel.x,5,vel.z))
			--else swim
			else
				self.object:add_velocity(acceleration)
			end
			self.swimming = true
		end
	end

	local get_group = minetest.get_node_group
	local get_node = minetest.get_node
	mob_register.hurt_inside = function(self,dtime)
		if self.hp > 0 and self.hurt_inside_timer <= 0 then
			local pos = self.object:getpos()
			local hurty = get_group(get_node(pos).name, "hurt_inside")
			if hurty > 0 then
				self.object:punch(self.object, 2, 
					{
					full_punch_interval=1.5,
					damage_groups = {damage=hurty},
				})
			end
		else
			self.hurt_inside_timer = self.hurt_inside_timer - dtime
		end
	end

	--This makes the mob walk at a certain speed and jump
	if def.movement_type == "walk" then
		mob_register.move = function(self,dtime)
			self.manage_jump_timer(self,dtime)
			self.timer = self.timer - dtime
			
			--jump
			self.jump(self)
			
			--swim
			self.swim(self,dtime)
			
			--print(self.timer)
			--direction state change
			if self.timer <= 0 and not self.following == true then
				--print("changing direction")
				self.timer = math.random(2,7)
				self.direction = vector.new(math.random()*math.random(-1,1),0,math.random()*math.random(-1,1))
				--local yaw = self.object:get_yaw() + dtime
				self.speed = math.random(0,self.max_speed)
				--self.object:set_yaw(yaw)
			end

			self.hurt_inside(self,dtime)

			local currentvel = self.object:getvelocity()
			local goal = vector.multiply(self.direction,self.speed)
			local acceleration = vector.new(goal.x-currentvel.x,0,goal.z-currentvel.z)
			acceleration = vector.multiply(acceleration, 0.05)
			self.object:add_velocity(acceleration)
		end
		--use raycasting to jump
		mob_register.jump = function(self)
			if self.jump_timer <= 0 then
				local vel = self.object:get_velocity()
				if (self.direction.x ~= 0 and vel.x == 0) or (self.direction.z ~= 0 and vel.z == 0) then
					local pos = self.object:get_pos()
					local ground_distance = self.object:get_properties().collisionbox[2]
					local ray = minetest.raycast(pos, vector.add(pos, vector.new(0,ground_distance*1.1,0)), false, false)	
					if ray then
						for pointed_thing in ray do
							local collision_point = pointed_thing.under
							if collision_point then
								local nodey = minetest.registered_nodes[minetest.get_node(collision_point).name]
								if nodey then
									local walkable = nodey.walkable
									if walkable then
										local distance = vector.subtract(collision_point,pos).y-self.object:get_properties().collisionbox[2]+0.4
										if distance >= -0.11 then
											local vel = self.object:get_velocity()
											self.jump_timer = 0.5
											self.object:add_velocity(vector.new(vel.x,5,vel.z))
										end
									end
								end
							end
						end
					end
				end
			end
		end
	elseif def.movement_type == "jump" then
		mob_register.move = function(self,dtime)
			self.manage_jump_timer(self,dtime)
			self.timer = self.timer - dtime
			
			--jump
			self.jump(self)
			
			--swim
			self.swim(self,dtime)
			
			--print(self.timer)
			--direction state change
			if self.timer <= 0 and not self.following == true then
				--print("changing direction")
				self.timer = math.random(2,7)
				self.direction = vector.new(math.random()*math.random(-1,1),0,math.random()*math.random(-1,1))
				--local yaw = self.object:get_yaw() + dtime
				self.speed = math.random(0,self.max_speed)
				--self.object:set_yaw(yaw)
			end

			self.hurt_inside(self,dtime)	
			
			local currentvel = self.object:getvelocity()
			if currentvel.y ~= 0 then
				local goal = vector.multiply(self.direction,self.speed)
				local acceleration = vector.new(goal.x-currentvel.x,0,goal.z-currentvel.z)
				acceleration = vector.multiply(acceleration, 0.05)
				self.object:add_velocity(acceleration)
			end
		end
		
		mob_register.jump = function(self)
			local vel = self.object:get_velocity()
			if self.jump_timer <= 0 then
				if vel.y == 0 and self.oldvely and self.oldvely <= 0 then --use <= on self.oldvely to make slime make landing sound
					minetest.sound_play("slime_splat", {object=self.object, gain = 1.0, max_hear_distance = 10,pitch = math.random(80,100)/100})
					local vel = self.object:get_velocity()
					self.jump_timer = 1+math.random()
					if self.hostile == true then
						self.jump_timer = 0.5
					end
					local goal = vector.multiply(self.direction,self.speed)
					self.object:set_velocity(vector.new(goal.x,5,goal.z))
				end
			end
			if vel.y == 0 and self.oldvely and self.oldvely < 0 then
				self.object:set_velocity(vector.new(0,0,0))
			end
			self.oldvely = vel.y
		end
	end
	
	
	return(mob_register)
end

