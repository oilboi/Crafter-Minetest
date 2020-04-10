local path = minetest.get_modpath("minecart")
dofile(path.."/rail.lua")

--this begins the minecart library
local minecart = {}


--these are the variables for the minecart
minecart.max_speed = 15
minecart.speed = 0
minecart.rider = nil

--binary direction
minecart.get_dir = function(pos,pos2)
	return(minetest.facedir_to_dir(minetest.dir_to_facedir(vector.direction(pos2,pos))))
end
--this gets the node position that the minecart is in
minecart.round_pos = function(pos)
	return(vector.round(pos))
end

--this is called when a player is standing next to the minecart
--it will take their position and convert it into binary then
--will begin movement 
minecart.set_direction = function(self,dir)
	if not self.goal then
		--reset the y to 0 since we will be checking up and down anyways
		dir.y = 0
		local pos = vector.add(minecart.round_pos(self.object:get_pos()),dir)	
		local node = minetest.get_node(pos).name
		local node_above = minetest.get_node(vector.new(pos.x,pos.y+1,pos.z)).name
		local node_under = minetest.get_node(vector.new(pos.x,pos.y-1,pos.z)).name
		
		--next to
		if node == "minecart:rail" and node_under ~= "minecart:rail" then
			self.dir = dir
			self.goal = pos
		--downhill
		elseif node == "air" and node_under == "minecart:rail" then
			self.dir = vector.new(dir.x,dir.y-1,dir.z)
			self.goal = vector.new(pos.x,pos.y-1,pos.z)
		--uphill
		elseif node ~= "minecart:rail" and node_above == "minecart:rail" then
			self.dir = vector.new(dir.x,dir.y+1,dir.z)
			self.goal = vector.new(pos.x,pos.y+1,pos.z)
		--rail not found
		else
			self.goal = nil
		end
	end
end

--this will turn the z into x and x into z
minecart.flip_direction_axis = function(self)
	self.dir = vector.new(math.abs(self.dir.z),0,math.abs(self.dir.x))
end

--this makes the minecart move in "blocks"
--it will go to it's goal then when it has reached the goal, move to another goal
minecart.movement = function(self)
	if self.dir and self.goal then
		local pos = self.object:get_pos()
		local movement = vector.direction(pos,self.goal)
		self.object:set_velocity(vector.multiply(movement,self.speed))
		local distance_from_goal = vector.distance(pos,self.goal)
		
		--this checks how far the minecart is from the "goal node"
		--aka the node that the minecart was supposed to go to
		if distance_from_goal < 0.2 then
			self.object:set_velocity(vector.new(0,0,0))
			self.goal = nil
			--self.object:move_to(minecart.round_pos(self.object:get_pos()))
			
			--if the minecart is slowed down below 1 nph (node per hour)
			--try to flip direction if pointing up
			--then stop it if failed
			if self.speed < 1 then
				if self.dir.y == 1 then
					self.dir = vector.multiply(self.dir, -1)
					minecart.set_direction(self,self.dir)
				else
					self.speed = 0
					self.dir = nil
					self.goal = nil
				end
				
			--otherwise try to keep going
			else
				--test to see if minecart will keep moving
				minecart.set_direction(self,self.dir)
				
				--if not rail ahead then we'll try to turn
				if not self.goal then					
					minecart.flip_direction_axis(self)
					
					minecart.set_direction(self,self.dir)
					
					--if trying to turn that direcion failed we'll try the other
					if not self.goal then
						self.dir = vector.multiply(self.dir, -1)
						minecart.set_direction(self,self.dir)
					end
				end
				
				--and if everything fails, give up and stop
				if not self.goal then
					self.speed = 0
				end
			end
		end
		
		--make minecart slow down, but only so much
		
		--speed up going downhill
		if self.dir and (self.dir.y == -1 or self.rider) and self.speed < 10 then
			self.speed = self.speed + 0.05
		--slow down going uphill
		elseif self.dir and self.speed > 1 and self.dir.y == 1 then
			self.speed = self.speed - 0.05
		--normal flat friction slowdown
		elseif self.speed > 1 then
			self.speed = self.speed - 0.01
		end
	--stop the minecart from flying off into the distance
	elseif not vector.equals(self.object:get_velocity(), vector.new(0,0,0)) and (self.speed == 0 or not self.speed) then
		self.object:set_velocity(vector.new(0,0,0))
	--this is when the minecart is stopped
	--gotta figure out some way to apply gravity and make it physical
	--without breaking the rest of it
	elseif self.speed == 0 then
		--self.object:add_velocity(vector.new(0,-10,0))
	end
	
	
end

--this simply sets the mesh based on if the minecart is moving up or down
--this will be replaced by set animation in the future
minecart.set_mesh = function(self)
	if self.dir and self.dir.y < 0  then
		self.object:set_animation({x=2,y=2}, 15, 0, true)
	elseif self.dir and self.dir.y > 0 then
		self.object:set_animation({x=1,y=1}, 15, 0, true)
	else
		self.object:set_animation({x=0,y=0}, 15, 0, true)
	end
end

minecart.on_step = function(self,dtime)
	local pos = self.object:get_pos()
	
	--get player input (standing next to the minecart)
	for _,object in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
		if self.object ~= object and object:is_player() and object:get_player_name() ~= self.rider then
			local pos2 = object:get_pos()
			minecart.set_direction(self, minecart.get_dir(pos,pos2))
			self.speed = 7
		end
	end	
	
	--this makes the minecart actually move, it is also
	--the begining of it's logic
	minecart.movement(self)
	
	--set the minecart's mesh
	minecart.set_mesh(self)
end

--make the player ride the minecart
--or make the player get off
minecart.on_rightclick = function(self,clicker)
	if not clicker or not clicker:is_player() then return end
	local name = clicker:get_player_name()
	
	--get on the minecart
	if not self.rider then
		self.rider = name
		clicker:set_attach(self.object, "", {x=0, y=0, z=0}, {x=0, y=0, z=0})
	--get off the minecart
	elseif name == self.rider then
		self.rider = nil
		clicker:set_detach()
	end
end

--get old data
minecart.on_activate = function(self,staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if string.sub(staticdata, 1, string.len("return")) ~= "return" then
		return
	end
	local data = minetest.deserialize(staticdata)
	if type(data) ~= "table" then
		return
	end
	self.dir = data.dir
	self.goal = data.goal
	self.speed = data.speed
	
	--run through if there was a rider then check if they exist and put them back on
	--and if they don't exist then nillify the rider value
	if data.rider then
		if minetest.player_exists(data.rider) then
			self.rider = data.rider
			local player = minetest.get_player_by_name(data.rider)
			player:set_attach(self.object, "", {x=0, y=0, z=0}, {x=0, y=0, z=0})
		else
			self.rider = nil
		end
	else
		self.rider = nil
	end
	
	
end
--remember data
minecart.get_staticdata = function(self)
	return minetest.serialize({
		dir = self.dir,
		goal = self.goal,
		speed = self.speed,
		rider = self.rider
	})
end



minecart.initial_properties = {
	physical = false, -- otherwise going uphill breaks
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 0.45, 0.4},--{-0.5, -0.4, -0.5, 0.5, 0.25, 0.5},
	visual = "mesh",
	mesh = "minecart.x",
	visual_size = {x=1, y=1},
	textures = {"minecart.png"},
	automatic_face_movement_dir = 90.0,
	automatic_face_movement_max_rotation_per_sec = 1200,
}


minecart.on_punch = function(self,puncher, time_from_last_punch, tool_capabilities, dir, damage)
	local obj = minetest.add_item(self.object:getpos(), "minecart:minecart")
	self.object:remove()
end

	

minetest.register_entity("minecart:minecart", minecart)












minetest.register_craftitem("minecart:minecart", {
	description = "Minecart",
	inventory_image = "minecartitem.png",
	wield_image = "minecartitem.png",
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
		
		if minetest.get_item_group(minetest.get_node(pointed_thing.under).name, "rail")>0 then
			minetest.add_entity(pointed_thing.under, "minecart:minecart")
		else
			return
		end

		itemstack:take_item()

		return itemstack
	end,
})

minetest.register_craft({
	output = "minecart:minecart",
	recipe = {
		{"main:iron", "", "main:iron"},
		{"main:iron", "main:iron", "main:iron"},
	},
})
