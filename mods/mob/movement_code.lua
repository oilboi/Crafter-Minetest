--this is where all the movement code is stored for the pig mob

--This makes the mob walk at a certain speed and jump
mob.move = function(self,dtime)
	self.timer = self.timer - dtime
	if self.timer <= 0 and self.following == false then
		self.timer = math.random(1,4)
		self.direction = vector.new(math.random()*math.random(-1,1),0,math.random()*math.random(-1,1))
		--local yaw = self.object:get_yaw() + dtime
		self.speed = math.random(1,5)
		--self.object:set_yaw(yaw)
	end
	
	local pos1 = self.object:getpos()
	pos1.y = pos1.y + 0.37
	local currentvel = self.object:getvelocity()
	local goal = vector.multiply(self.direction,self.speed)
	local acceleration = vector.new(goal.x-currentvel.x,0,goal.z-currentvel.z)
	acceleration = vector.multiply(acceleration, 0.05)
	self.object:add_velocity(acceleration)
end

--use raycasting to jump
mob.jump = function(self)	
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
					--print(distance)
					if distance >= -0.11 then
						self.object:add_velocity(vector.new(0,5,0))
					end
				end
			end
		end
	end
end
