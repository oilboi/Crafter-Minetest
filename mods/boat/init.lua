--minetest.get_node_level(pos)
minetest.register_entity("boat:boat", {
	initial_properties = {
		hp_max = 1,
		physical = true,
		collide_with_objects = false,
		collisionbox = {-0.4, -0.35, -0.4, 0.4, 0.3, 0.4},
		visual = "mesh",
		mesh = "boat.obj",
		textures = {"boat.png"},
		visual_size = {x=3,y=3,z=3},
		is_visible = true,
		automatic_face_movement_dir = 90.0,
		automatic_face_movement_max_rotation_per_sec = 600,
	},
	
	rider = nil,


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
		self.object:set_acceleration({x = 0, y = -9.81, z = 0})
	end,
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		local pos = self.object:getpos()
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
			self.rider = nil
		elseif not self.rider then
			self.rider = player_name
			clicker:set_attach(self.object, "", {x=0, y=-4.5, z=0}, {x=0, y=0, z=0})
			--player:set_eye_offset({x=0, y=-4, z=0},{x=0, y=-4, z=0})
			--carts:manage_attachment(clicker, self.object)

			-- player_api does not update the animation
			-- when the player is attached, reset to default animation
			
			--player_api.set_animation(clicker, "stand")
		end
	end,
	--check if the boat is stuck on land
	check_if_on_land = function(self)
		local pos = self.object:getpos()
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
				local currentvel = self.object:getvelocity()
				local goal = rider:get_look_dir()
				goal = vector.multiply(goal,9)
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
		local pos = self.object:getpos()
		for _,object in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
			if object:is_player() and object:get_player_name() ~= self.rider then
				local player_pos = object:getpos()
				pos.y = 0
				player_pos.y = 0
				
				local currentvel = self.object:getvelocity()
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
		local pos = self.object:getpos()
		local node = minetest.get_node(pos).name
		self.swimming = false
		
		--flow normally if floating else don't
		if node == "main:water" or node =="main:waterflow" then
			self.swimming = true
			local vel = self.object:getvelocity()
			local goal = 3
			local acceleration = vector.new(0,goal-vel.y,0)
			self.object:add_velocity(acceleration)
		end
	end,
	
	--makes boats flow
	flow = function(self)
		local pos = self.object:getpos()
		pos.y = pos.y - 0.4
		local node = minetest.get_node(pos).name
		local node_above = minetest.get_node(vector.new(pos.x,pos.y+1,pos.z)).name
		local goalx = 0
		local goalz = 0
		--print(node_above)
		if (node == "main:waterflow" or node == "main:water" ) and not self.moving == true and (node_above ~= "main:water" and node_above ~= "main:waterflow") then
			local currentvel = self.object:getvelocity()
			local level = minetest.get_node_level(pos)
			local pos = self.object:getpos()
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
			local vel = self.object:getvelocity()
			local deceleration = vector.multiply(vel, -0.01)
			self.object:add_velocity(deceleration)
		end
	end,

	on_step = function(self, dtime)
		self.check_if_on_land(self)
		self.push(self)
		self.drive(self)
		self.float(self)
		self.flow(self)
		self.slowdown(self)
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
