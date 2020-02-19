--minetest.get_node_level(pos)
minetest.register_entity("boat:boat", {
	initial_properties = {
		hp_max = 1,
		physical = true,
		collide_with_objects = false,
		collisionbox = {-0.5, -0.35, -0.5, 0.5, 0.3, 0.5},
		visual = "mesh",
		mesh = "boat.obj",
		textures = {"boat.png"},
		visual_size = {x=3,y=3,z=3},
		is_visible = true,
	},
	
	rider = "",


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
			end
		end
	end,
	
	--makes the boat float
	float = function(self)
		local pos = self.object:getpos()
		local node = minetest.get_node(pos).name
		local vel = self.object:getvelocity()
		local goal = 1
		local acceleration = vector.new(0,goal-vel.y,0)
		self.swimming = false
		
		if node == "main:water" or node =="main:waterflow" then
			print("float man")
			self.swimming = true
			self.object:add_velocity(acceleration)
		end
	end,
	
	
	--slows the boat down
	slowdown = function(self)
		local vel = self.object:getvelocity()
		local deceleration = vector.multiply(vel, -0.01)
		self.object:add_velocity(deceleration)
		
	
	
	end,

	on_step = function(self, dtime)
		self.push(self)
		self.float(self)
		self.slowdown(self)
	end,
})
