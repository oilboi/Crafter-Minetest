--minetest.get_node_level(pos)
minetest.register_entity("boat:boat", {
	initial_properties = {
		hp_max = 1,
		physical = true,
		collide_with_objects = false,
		collisionbox = {-0.4, 0, -0.4, 0.4, 0.5, 0.4},
		visual = "mesh",
		mesh = "boat.x",
		textures = {"boat.png"},
		visual_size = {x=1,y=1,z=1},
		is_visible = true,
		automatic_face_movement_dir = -90.0,
		automatic_face_movement_max_rotation_per_sec = 600,
	},
	
	rider = nil,
	boat = true,

	get_staticdata = function(self)
		return minetest.serialize({
			--itemstring = self.itemstring,
		})
	end,

	on_activate = function(self, staticdata, dtime_s)
		if string.sub(staticdata, 1, string.len("return")) == "return" then
			local data = minetest.deserialize(staticdata)
			if data and type(data) == "table" then
				--self.itemstring = data.itemstring
			end
		else
			--self.itemstring = staticdata
		end
		self.object:set_armor_groups({immortal = 1})
		self.object:set_velocity({x = 0, y = 0, z = 0})
		self.object:set_acceleration({x = 0, y = 0, z = 0})
	end,
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		local pos = self.object:get_pos()
		minetest.add_item(pos, "boat:boat")
		self.object:remove()
	end,
	
	
	on_rightclick = function(self,clicker)
		if not clicker or not clicker:is_player() then
			return
		end
		local player_name = clicker:get_player_name()
		
		if self.rider and player_name == self.rider then
			clicker:set_detach()
			local pos = self.object:get_pos()
			pos.y = pos.y + 1
			clicker:move_to(pos)
			clicker:add_player_velocity(vector.new(0,11,0))
			self.rider = nil
			
			player_is_attached(clicker,false)
			force_update_animation(clicker)

		elseif not self.rider then
			self.rider = player_name
			clicker:set_attach(self.object, "", {x=0, y=2, z=0}, {x=0, y=0, z=0})
			
			set_player_animation(clicker,"sit",0)
			player_is_attached(clicker,true)
		end
	end,
	--check if the boat is stuck on land
	check_if_on_land = function(self)
		local pos = self.object:get_pos()
		pos.y = pos.y - 0.37
		local bottom_node = minetest.get_node(pos).name
		if (bottom_node == "main:water" or bottom_node == "main:waterflow" or bottom_node == "air") then
			self.on_land = false
		else
			self.on_land = true
		end
	
	end,
	
	--players drive the baot
	drive = function(self)
		if self.rider and not self.on_land == true then
			local rider = minetest.get_player_by_name(self.rider)
			local move = rider:get_player_control().up
			self.moving = nil
			if move then
				local currentvel = self.object:get_velocity()
				local goal = rider:get_look_dir()
				goal = vector.multiply(goal,20)
				local acceleration = vector.new(goal.x-currentvel.x,0,goal.z-currentvel.z)
				acceleration = vector.multiply(acceleration, 0.01)
				self.object:add_velocity(acceleration)
				self.moving = true
			end
		else
			self.moving = nil
		end
	end,
	
	--players push boat
	push = function(self)
		local pos = self.object:get_pos()
		for _,object in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
			if object:is_player() and object:get_player_name() ~= self.rider then
				local player_pos = object:get_pos()
				pos.y = 0
				player_pos.y = 0
				
				local currentvel = self.object:get_velocity()
				local vel = vector.subtract(pos, player_pos)
				vel = vector.normalize(vel)
				local distance = vector.distance(pos,player_pos)
				distance = (1-distance)*10
				vel = vector.multiply(vel,distance)
				local acceleration = vector.new(vel.x-currentvel.x,0,vel.z-currentvel.z)
				self.object:add_velocity(acceleration)
				acceleration = vector.multiply(acceleration, -1)
				object:add_player_velocity(acceleration)
			end
		end
	end,
	
	--makes the boat float
	float = function(self)
		local pos = self.object:get_pos()
		local node = minetest.get_node(pos).name
		self.swimming = false
		
		--flow normally if floating else don't
		if node == "main:water" or node =="main:waterflow" then
			self.object:set_acceleration(vector.new(0,0,0))
			self.swimming = true
			local vel = self.object:get_velocity()
			local goal = 9
			local acceleration = vector.new(0,goal-vel.y,0)
			acceleration = vector.multiply(acceleration, 0.01)
			self.object:add_velocity(acceleration)
			--self.object:set_acceleration(vector.new(0,0,0))
		else
			self.object:set_acceleration(vector.new(0,-10,0))
		end
	end,
	
	--makes boats flow
	flow = function(self)
		local pos = self.object:get_pos()
		pos.y = pos.y - 0.4
		local node = minetest.get_node(pos).name
		local node_above = minetest.get_node(vector.new(pos.x,pos.y+1,pos.z)).name
		local goalx = 0
		local goalz = 0
		--print(node_above)
		if (node == "main:waterflow" or node == "main:water" ) and not self.moving == true and (node_above ~= "main:water" and node_above ~= "main:waterflow") then
			local currentvel = self.object:get_velocity()
			local level = minetest.get_node_level(pos)
			local pos = self.object:get_pos()
			for x = -1,1 do
				for y = -1,0 do
					for z = -1,1 do
						if (x == 0 and z ~= 0) or (z == 0 and x ~=0) then
							local nodename = minetest.get_node(vector.new(pos.x+x,pos.y+y,pos.z+z)).name
							local level2 = minetest.get_node_level(vector.new(pos.x+x,pos.y+y,pos.z+z))
							if (level2 < level and nodename == "main:waterflow") or (nodename == "main:water" and level2 == 7)  then
								goalx = x*7
								goalz = z*7
								--break
							end
						end
					end
				end
			end
			--only add velocity if there is one
			--else this stops the boat
			if goalx ~= 0 or goalz ~= 0 then
				local acceleration = vector.new(goalx-currentvel.x,0,goalz-currentvel.z)
				acceleration = vector.multiply(acceleration, 0.01)
				self.object:add_velocity(acceleration)
			end
		end
	end,
	
	
	--slows the boat down
	slowdown = function(self)
		if not self.moving == true then
			local vel = self.object:get_velocity()
			local acceleration = vector.new(-vel.x,0,-vel.z)
			local deceleration = vector.multiply(acceleration, 0.01)
			self.object:add_velocity(deceleration)
		end
	end,

	lag_correction = function(self,dtime)
		local pos = self.object:get_pos()
		local velocity = self.object:get_velocity()
		if self.lag_check then
			local chugent = math.ceil(minetest.get_us_time()/1000 - self.lag_check)

			--print("lag = "..chugent.." ms")
			if chugent > 70 and  self.old_pos and self.old_velocity then
				self.object:move_to(self.old_pos)
				self.object:set_velocity(self.old_velocity)
			end
		end
		self.old_pos = pos
		self.old_velocity = vel
		self.lag_check = minetest.get_us_time()/1000
	end,

	on_step = function(self, dtime)
		self.check_if_on_land(self)
		self.push(self)
		self.drive(self)
		self.float(self)
		self.flow(self)
		self.slowdown(self)
		self.lag_correction(self,dtime)
	end,
})

minetest.register_craftitem("boat:boat", {
	description = "Boat",
	inventory_image = "boatitem.png",
	wield_image = "boatitem.png",
	liquids_pointable = true,
	on_place = function(itemstack, placer, pointed_thing)
		if not pointed_thing.type == "node" then
			return
		end
		
		local sneak = placer:get_player_control().sneak
		local noddef = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]
		if not sneak and noddef.on_rightclick then
			minetest.item_place(itemstack, placer, pointed_thing)
			return
		end
		
		if minetest.get_item_group(minetest.get_node(pointed_thing.under).name, "water")>0 then
			minetest.add_entity(pointed_thing.under, "boat:boat")
		else
			return
		end

		itemstack:take_item()

		return itemstack
	end,
})

minetest.register_craft({
	output = "boat:boat",
	recipe = {
		{"main:wood", "", "main:wood"},
		{"main:wood", "main:wood", "main:wood"},
	},
})

----------------------------------



minetest.register_entity("boat:iron_boat", {
	initial_properties = {
		hp_max = 1,
		physical = true,
		collide_with_objects = false,
		collisionbox = {-0.4, 0, -0.4, 0.4, 0.5, 0.4},
		visual = "mesh",
		mesh = "boat.x",
		textures = {"iron_boat.png"},
		visual_size = {x=1,y=1,z=1},
		is_visible = true,
		automatic_face_movement_dir = -90.0,
		automatic_face_movement_max_rotation_per_sec = 600,
	},
	
	rider = nil,
	iron_boat = true,

	get_staticdata = function(self)
		return minetest.serialize({
			--itemstring = self.itemstring,
		})
	end,

	on_activate = function(self, staticdata, dtime_s)
		if string.sub(staticdata, 1, string.len("return")) == "return" then
			local data = minetest.deserialize(staticdata)
			if data and type(data) == "table" then
				--self.itemstring = data.itemstring
			end
		else
			--self.itemstring = staticdata
		end
		self.object:set_armor_groups({immortal = 1})
		self.object:set_velocity({x = 0, y = 0, z = 0})
		self.object:set_acceleration({x = 0, y = 0, z = 0})
	end,
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		local pos = self.object:get_pos()
		minetest.add_item(pos, "boat:iron_boat")
		self.object:remove()
	end,
	
	
	on_rightclick = function(self,clicker)
		if not clicker or not clicker:is_player() then
			return
		end
		local player_name = clicker:get_player_name()
		
		if self.rider and player_name == self.rider then
			clicker:set_detach()
			local pos = self.object:get_pos()
			pos.y = pos.y + 1
			clicker:move_to(pos)
			clicker:add_player_velocity(vector.new(0,11,0))
			self.rider = nil
			
			player_is_attached(clicker,false)
			force_update_animation(clicker)

		elseif not self.rider then
			self.rider = player_name
			clicker:set_attach(self.object, "", {x=0, y=2, z=0}, {x=0, y=0, z=0})
			
			set_player_animation(clicker,"sit",0)
			player_is_attached(clicker,true)
		end
	end,
	--check if the boat is stuck on land
	check_if_on_land = function(self)
		local pos = self.object:get_pos()
		pos.y = pos.y - 0.37
		local bottom_node = minetest.get_node(pos).name
		if (bottom_node == "nether:lava" or bottom_node == "nether:lavaflow" or bottom_node == "air") then
			self.on_land = false
		else
			self.on_land = true
		end
	
	end,
	
	--players drive the baot
	drive = function(self)
		if self.rider and not self.on_land == true then
			local rider = minetest.get_player_by_name(self.rider)
			local move = rider:get_player_control().up
			self.moving = nil
			if move then
				local currentvel = self.object:get_velocity()
				local goal = rider:get_look_dir()
				goal = vector.multiply(goal,20)
				local acceleration = vector.new(goal.x-currentvel.x,0,goal.z-currentvel.z)
				acceleration = vector.multiply(acceleration, 0.01)
				self.object:add_velocity(acceleration)
				self.moving = true
			end
		else
			self.moving = nil
		end
	end,
	
	--players push boat
	push = function(self)
		local pos = self.object:get_pos()
		for _,object in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
			if object:is_player() and object:get_player_name() ~= self.rider then
				local player_pos = object:get_pos()
				pos.y = 0
				player_pos.y = 0
				
				local currentvel = self.object:get_velocity()
				local vel = vector.subtract(pos, player_pos)
				vel = vector.normalize(vel)
				local distance = vector.distance(pos,player_pos)
				distance = (1-distance)*10
				vel = vector.multiply(vel,distance)
				local acceleration = vector.new(vel.x-currentvel.x,0,vel.z-currentvel.z)
				self.object:add_velocity(acceleration)
				acceleration = vector.multiply(acceleration, -1)
				object:add_player_velocity(acceleration)
			end
		end
	end,
	
	--makes the boat float
	float = function(self)
		local pos = self.object:get_pos()
		local node = minetest.get_node(pos).name
		self.swimming = false
		
		--flow normally if floating else don't
		if node == "nether:lava" or node =="nether:lavaflow" then
			self.swimming = true
			local vel = self.object:get_velocity()
			local goal = 9
			local acceleration = vector.new(0,goal-vel.y,0)
			acceleration = vector.multiply(acceleration, 0.01)
			self.object:add_velocity(acceleration)
			--self.object:set_acceleration(vector.new(0,0,0))
		else
			local vel = self.object:get_velocity()
			local goal = -9.81
			local acceleration = vector.new(0,goal-vel.y,0)
			acceleration = vector.multiply(acceleration, 0.01)
			self.object:add_velocity(acceleration)
			--self.object:set_acceleration(vector.new(0,0,0))
		end
	end,
	
	--makes boats flow
	flow = function(self)
		local pos = self.object:get_pos()
		pos.y = pos.y - 0.4
		local node = minetest.get_node(pos).name
		local node_above = minetest.get_node(vector.new(pos.x,pos.y+1,pos.z)).name
		local goalx = 0
		local goalz = 0
		--print(node_above)
		if (node == "nether:lavaflow" or node == "nether:lava" ) and not self.moving == true and (node_above ~= "nether:lava" and node_above ~= "nether:lavaflow") then
			local currentvel = self.object:get_velocity()
			local level = minetest.get_node_level(pos)
			local pos = self.object:get_pos()
			for x = -1,1 do
				for y = -1,0 do
					for z = -1,1 do
						if (x == 0 and z ~= 0) or (z == 0 and x ~=0) then
							local nodename = minetest.get_node(vector.new(pos.x+x,pos.y+y,pos.z+z)).name
							local level2 = minetest.get_node_level(vector.new(pos.x+x,pos.y+y,pos.z+z))
							if (level2 < level and nodename == "main:lavaflow") or (nodename == "main:lava" and level2 == 7)  then
								goalx = x*7
								goalz = z*7
								--break
							end
						end
					end
				end
			end
			--only add velocity if there is one
			--else this stops the boat
			if goalx ~= 0 or goalz ~= 0 then
				local acceleration = vector.new(goalx-currentvel.x,0,goalz-currentvel.z)
				acceleration = vector.multiply(acceleration, 0.01)
				self.object:add_velocity(acceleration)
			end
		end
	end,
	
	
	--slows the boat down
	slowdown = function(self)
		if not self.moving == true then
			local vel = self.object:get_velocity()
			local acceleration = vector.new(-vel.x,0,-vel.z)
			local deceleration = vector.multiply(acceleration, 0.01)
			self.object:add_velocity(deceleration)
		end
	end,

	lag_correction = function(self,dtime)
		local pos = self.object:get_pos()
		local velocity = self.object:get_velocity()
		if self.lag_check then
			local chugent = math.ceil(minetest.get_us_time()/1000- self.lag_check)

			--print("lag = "..chugent.." ms")
			if chugent > 70 and  self.old_pos and self.old_velocity then
				self.object:move_to(self.old_pos)
				self.object:set_velocity(self.old_velocity)
			end
		end
		self.old_pos = pos
		self.old_velocity = vel
		self.lag_check = minetest.get_us_time()/1000
	end,

	on_step = function(self, dtime)
		self.check_if_on_land(self)
		self.push(self)
		self.drive(self)
		self.float(self)
		self.flow(self)
		self.slowdown(self)
		self.lag_correction(self,dtime)
	end,
})

minetest.register_craftitem("boat:iron_boat", {
	description = "Iron Boat",
	inventory_image = "iron_boatitem.png",
	wield_image = "iron_boatitem.png",
	liquids_pointable = true,
	on_place = function(itemstack, placer, pointed_thing)
		if not pointed_thing.type == "node" then
			return
		end
		
		local sneak = placer:get_player_control().sneak
		local noddef = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]
		if not sneak and noddef.on_rightclick then
			minetest.item_place(itemstack, placer, pointed_thing)
			return
		end
		
		if pointed_thing.above.y < -10000 and pointed_thing.above.y > -20000 then
			minetest.add_entity(pointed_thing.under, "boat:iron_boat")
		else
			return
		end

		itemstack:take_item()

		return itemstack
	end,
})

minetest.register_craft({
	output = "boat:iron_boat",
	recipe = {
		{"main:iron", "main:coal", "main:iron"},
		{"main:iron", "main:iron", "main:iron"},
	},
})
