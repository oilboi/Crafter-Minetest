local
minetest,math,vector,pairs,table
=
minetest,math,vector,pairs,table

local pos
local node
local vel
local goal
local acceleration
local hurt
local fire
local currentvel
local goal
local y
local modifier
local pos2
local ray
local pointed_thing

local acute_pos
local height_diff
local acute_following_pos
local min
local max
local index_table
local path
local number
local pos1
local pos3
local can_cut
local _

--index all mods
local all_walkable_nodes = {}
minetest.register_on_mods_loaded(function()
	for name in pairs(minetest.registered_nodes) do
		if name ~= "air" and name ~= "ignore" then
			if minetest.get_nodedef(name,"walkable") then
				table.insert(all_walkable_nodes,name)
			end
		end
	end
end)

mobs.create_movement_functions = function(def,mob_register)
	--makes the mob swim
	mob_register.swim = function(self,dtime)
		pos = self.object:get_pos()
		pos.y = pos.y + 0.3
		node = minetest.get_node(pos).name
		self.swimming = false
		if node == "main:water" or node =="main:waterflow" then
			vel = self.object:get_velocity()
			goal = 3
			acceleration = vector.new(0,goal-vel.y,0)
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

	mob_register.hurt_inside = function(self,dtime)
		if self.hp > 0 and self.hurt_inside_timer <= 0 then
			pos = self.object:get_pos()
			node = minetest.get_node(pos).name
			hurt = minetest.get_item_group(node, "hurt_inside")
			if hurt > 0 then
				self.object:punch(self.object, 2, 
					{
					full_punch_interval=1.5,
					damage_groups = {damage=hurt},
				})
			end
			fire = minetest.get_item_group(node, "fire")
			if not self.on_fire and fire > 0 then
				start_fire(self.object)
			end
			self.hurt_inside_timer = 0.25
		else
			self.hurt_inside_timer = self.hurt_inside_timer - dtime
		end
	end

	--This makes the mob walk at a certain speed and jump
	if def.movement_type == "walk" then
		mob_register.move = function(self,dtime,moveresult)
			self.manage_jump_timer(self,dtime)
			self.timer = self.timer - dtime

			--jump
			self.jump(self,moveresult)
			
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

			currentvel = self.object:get_velocity()
			goal = vector.multiply(self.direction,self.speed)
			acceleration = vector.new(goal.x-currentvel.x,0,goal.z-currentvel.z)
			if self.whip_turn then
				self.whip_turn = self.whip_turn - dtime
				if self.whip_turn <= 0 then
					self.whip_turn = nil
				end
			else
				acceleration = vector.multiply(acceleration, 0.05)
			end
			self.object:add_velocity(acceleration)
		end
		mob_register.jump = function(self,moveresult)
			if moveresult and moveresult.touching_ground and self.direction then
				pos = self.object:get_pos()
				pos.y = pos.y+0.1

				if self.path_data and table.getn(self.path_data) > 0 then
					--smart jump
					y = math.floor(pos.y+0.5)
					vel = self.object:get_velocity()
					if y < self.path_data[1].y then
						self.object:set_velocity(vector.new(vel.x,5,vel.z))
					elseif self.path_data[2] and y < self.path_data[2].y then
						self.object:set_velocity(vector.new(vel.x,5,vel.z))
					elseif self.path_data[3] and y < self.path_data[3].y then
						self.object:set_velocity(vector.new(vel.x,5,vel.z))
					elseif ((vel.x == 0 and self.direction.x ~= 0) or (vel.z == 0 and self.direction.z ~= 0)) then
						self.object:set_velocity(vector.new(vel.x,5,vel.z))
					end
				else
					--assume collisionbox is even x and z
					modifier = self.object:get_properties().collisionbox[4]*3
					

					pos2 = vector.add(vector.multiply(self.direction,modifier),pos)

					ray = minetest.raycast(pos, pos2, false, false)
					
					pointed_thing = nil

					if ray then
						pointed_thing = ray:next()
					end
						
					if pointed_thing then
						if minetest.get_nodedef(minetest.get_node(pointed_thing.under).name, "walkable") then
							--print("jump")
							vel = self.object:get_velocity()
							--self.jump_timer = 1+math.random()
							self.object:set_velocity(vector.new(vel.x,5,vel.z))
						else
							--print("velocity check")
							vel = self.object:get_velocity()
							if (vel.x == 0 and self.direction.x ~= 0) or (vel.z == 0 and self.direction.z ~= 0) then
								self.object:set_velocity(vector.new(vel.x,5,vel.z))
							end
						end
					else
						--print("velcheck 2")
						vel = self.object:get_velocity()
						if (vel.x == 0 and self.direction.x ~= 0) or (vel.z == 0 and self.direction.z ~= 0) then
							self.object:set_velocity(vector.new(vel.x,5,vel.z))
						end
					end
				end
			end
		end
	elseif def.movement_type == "jump" then
		mob_register.move = function(self,dtime,moveresult)
			self.manage_jump_timer(self,dtime)
			self.timer = self.timer - dtime
			
			--jump
			self.jump(self,moveresult)
			
			--swim
			self.swim(self,dtime)
			
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
			
			currentvel = self.object:get_velocity()
			if currentvel.y ~= 0 then
				goal = vector.multiply(self.direction,self.speed)
				acceleration = vector.new(goal.x-currentvel.x,0,goal.z-currentvel.z)
				acceleration = vector.multiply(acceleration, 0.05)
				self.object:add_velocity(acceleration)
			end
		end
		
		mob_register.jump = function(self,moveresult)
			if moveresult and moveresult.touching_ground and self.direction then
				if self.jump_timer <= 0 then
					if self.make_jump_noise then
						minetest.sound_play("slime_splat", {object=self.object, gain = 1.0, max_hear_distance = 10,pitch = math.random(80,100)/100})
					end
					vel = self.object:get_velocity()
					self.object:set_velocity(vector.new(vel.x,5,vel.z))
					if self.following == true then
						self.jump_timer = 0.5
					else
						self.jump_timer = 1+math.random()
					end
				else
					self.object:set_velocity(vector.new(0,0,0))
				end
			end
		end
	end
	
	if def.pathfinds then
		mob_register.pathfinding = function(self,dtime)
			acute_pos = vector.floor(vector.add(self.object:get_pos(),0.5))
			if self.following and self.following_pos then
				self.pathfinding_timer = self.pathfinding_timer + dtime
				height_diff = nil
				if self.object:get_pos().y > self.following_pos.y then
					height_diff = math.abs(self.object:get_pos().y-self.following_pos.y)
				elseif self.object:get_pos().y <= self.following_pos.y then
					height_diff = math.abs(self.following_pos.y-self.object:get_pos().y)
				end
				--delete path if height too far
				if self.path_data and height_diff > self.view_distance/2 then
					self.path_data = nil
					self.old_path_pos = nil
					self.old_acute_following_pos = nil
					return
				end

				if self.pathfinding_timer >= 0.5 and height_diff <= self.view_distance/2 then
					acute_following_pos = vector.floor(vector.add(self.following_pos,0.5))

					if (not self.old_path_pos or (self.old_path_pos and not vector.equals(acute_pos,self.old_path_pos))) and
							(not self.old_acute_following_pos or (self.old_acute_following_pos and vector.distance(self.old_acute_following_pos,acute_following_pos) > 2)) then
						
						--if a player tries to hide in a node
						if minetest.get_nodedef(minetest.get_node(acute_following_pos).name, "walkable") then
							acute_following_pos.y = acute_following_pos.y + 1
						end

						--if a player tries to stand off the side of a node
						if not minetest.get_nodedef(minetest.get_node(vector.new(acute_following_pos.x,acute_following_pos.y-1,acute_following_pos.z)).name, "walkable") then
							min = vector.subtract(acute_following_pos,1)
							max = vector.add(acute_following_pos,1)

							index_table = minetest.find_nodes_in_area_under_air(min, max, all_walkable_nodes)
							--optimize this as much as possible
							for _,i_pos in pairs(index_table) do
								if minetest.get_nodedef(minetest.get_node(i_pos).name, "walkable") then
									acute_following_pos = vector.new(i_pos.x,i_pos.y+1,i_pos.z)
									break
								end
							end
						end
						
						path = minetest.find_path(acute_pos,acute_following_pos,self.view_distance,1,1,"A*_noprefetch")
						--if the path fails then raycast down to scare player or accidentally find new path
						--disabled for extreme cpu usage
						--[[
						if not path then
							local ray = minetest.raycast(acute_following_pos, vector.new(acute_following_pos.x,acute_following_pos.y-self.view_distance,acute_following_pos.z), false, false)
							for pointed_thing in ray do
								if pointed_thing.above then
									path = minetest.find_path(self.object:get_pos(),pointed_thing.above,self.view_distance,1,5,"A*_noprefetch")
									break
								end
							end
						end
						]]--
						if path then
							self.whip_turn = 0.025
							self.path_data = path

							--remove the first element of the list
							--shift whole list down
							for i = 2,table.getn(self.path_data) do
								self.path_data[i-1] = self.path_data[i]
							end
							self.path_data[table.getn(self.path_data)] = nil
							
							--cut corners (go diagonal)
							if self.path_data and table.getn(self.path_data) >= 3 then
								number = 3
								for i = 3,table.getn(self.path_data) do
									pos1 = self.path_data[number-2]
									pos2 = self.path_data[number]

									--print(number)
									--check if diagonal and has direct line of sight
									if pos1 and pos2 and pos1.x ~= pos2.x and pos1.z ~= pos2.z and pos1.y == pos2.y then
										pos3 = vector.divide(vector.add(pos1,pos2),2)
										pos3.y = pos3.y - 1
										can_cut,_ = minetest.line_of_sight(pos1, pos2)
										if can_cut then

											if minetest.get_nodedef(minetest.get_node(pos3).name, "walkable") == true then
												--shift whole list down
												--print("removing"..number-1)
												for z = number-1,table.getn(self.path_data) do
													self.path_data[z-1] = self.path_data[z]
												end
												self.path_data[table.getn(self.path_data)] = nil
												number = number + 2
											else
												number = number + 1
											end
										else
											number = number + 1
										end
										if number > table.getn(self.path_data) then
											break
										end
									else
										number = number + 1
									end
								end
								--if self.path_data and table.getn(self.path_data) <= 2 then
								--	self.path_data = nil
								--end
							end
						end
												
						self.old_path_pos = acute_pos
						self.old_acute_following_pos = acute_following_pos	
					end
				end
			elseif (not self.following and self.path_data) or (self.path_data and height_diff > self.view_distance/2) then
				self.path_data = nil
				self.old_path_pos = nil
				self.old_acute_following_pos = nil
			end
			--[[
			if self.path_data then
				for index,pos_data in pairs(self.path_data) do
					--print(dump(pos_data))
					minetest.add_particle({
						pos = pos_data,
						velocity = {x=0, y=0, z=0},
						acceleration = {x=0, y=0, z=0},
						expirationtime = 0.01,
						size = 1,
						texture = "dirt.png",
					})
				end
			end
			]]--
			--this is the real time path deletion as it goes along it
			if self.swimming == true then
				self.path_data = nil
			end

			if self.path_data and table.getn(self.path_data) > 0 then
				if vector.distance(acute_pos,self.path_data[1]) <= 1 then
					--shift whole list down
					for i = 2,table.getn(self.path_data) do
						self.path_data[i-1] = self.path_data[i]
					end
					self.path_data[table.getn(self.path_data)] = nil
					self.whip_turn = 0.05
					--if table.getn(self.path_data) == 0 then
					--	self.path_data = nil
					--end
				end
			end
			--charge at the player
			if self.path_data and table.getn(self.path_data) < 2 then
				self.path_data = nil
			end

		end
	end
	
	return(mob_register)
end

