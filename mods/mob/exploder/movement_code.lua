--this is where all the movement code is stored for the pig mob

--This makes the mob walk at a certain speed and jump
exploder.move = function(self,dtime)
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
		self.speed = math.random(0,6)
		--self.object:set_yaw(yaw)
	end

	local currentvel = self.object:getvelocity()
	local goal = vector.multiply(self.direction,self.speed)
	local acceleration = vector.new(goal.x-currentvel.x,0,goal.z-currentvel.z)
	acceleration = vector.multiply(acceleration, 0.05)
	self.object:add_velocity(acceleration)
end

--use raycasting to jump
exploder.jump = function(self)
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
						local walkable = minetest.registered_nodes[minetest.get_node(collision_point).name].walkable
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

--makes the mob swim
exploder.swim = function(self,dtime)
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
