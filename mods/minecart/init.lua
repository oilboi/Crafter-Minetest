local path = minetest.get_modpath("minecart")
dofile(path.."/rail.lua")


--get if rail
local function rail(pos)
	return(minetest.get_node_group(minetest.get_node(pos).name,"rail")>0)
end

--check if on rail
local function on_rail(self,pos)
	if not rail(pos) and not self.slope then
		self.axis = nil
		return(false)
	else
		return(true)
	end
end

--set physical state
local function physical(self,pos)
	if on_rail(self,pos) then
		self.object:set_properties({physical = false})
		self.object:setacceleration(vector.new(0,0,0))
	elseif not self.slope then
		self.object:set_properties({physical = true})
		self.object:setacceleration(vector.new(0,-9.81,0))
	end
end

--get if node in minecarts direction
local function node_ahead(self,pos)
	local vel = self.object:getvelocity()
	local dir = vector.normalize(vel)
	return(rail(vector.add(pos,dir)))
end

--get current axis (prefers x)
local function axis(pos)
	if rail(pos) then
		if rail(vector.new(pos.x-1,pos.y,pos.z)) or rail(vector.new(pos.x+1,pos.y,pos.z)) then return("x") end
		if rail(vector.new(pos.x,pos.y,pos.z-1)) or rail(vector.new(pos.x,pos.y,pos.z+1)) then return("z") end
	end
end

--snap object to rail
local function snap_rail(self,pos)
	local slopy = self.slope
	if not slopy then print("the slope is nil") else
		print("the slope is ".. slopy)
	end
	local railpos = vector.floor(vector.add(pos, 0.5))
	local vel = self.object:getvelocity()
	if self.axis == "x" and pos.x ~= railpos.x then
		self.object:moveto(vector.new(pos.x,railpos.y,railpos.z))
		self.object:setvelocity(vector.new(vel.x,0,0))
		print("snapped to x")
		return
	end
	if self.axis == "z" and pos.z ~= railpos.z then
		self.object:moveto(vector.new(railpos.x,railpos.y,pos.z))
		self.object:setvelocity(vector.new(0,0,vel.z))
		print("snapped to z")
		return
	end
end

--check if entering new position
local function newnode(self,pos)
	local pos = vector.floor(vector.add(pos,0.5))
	
	pos.y = 0
	
	local equals = false
	
	
	if self.oldpos then
		equals = vector.equals(pos,self.oldpos)
	end
	
	self.oldpos = pos
	return(not equals)
end

--check if past center - used for turning
local function pastcenter(self,pos)
	
	local center = vector.floor(vector.add(pos,0.5))
	center.y = 0
	local pos2d = vector.new(pos.x,0,pos.z)
	
	local vel = self.object:getvelocity()
	local dir = vector.normalize(vel)
	dir.y = 0
	local checker = vector.round(vector.normalize(vector.subtract(pos2d,center)))
	checker.y = 0
	local past = vector.equals(checker, dir)
	return(past)
end

--check if node ahead
local function node_forward(self,pos)
	local vel = self.object:getvelocity()
	local dir = vector.normalize(vel)
	return(rail(vector.add(pos,dir)))
end

--check if node above or below
local function check_hill(self,pos)
	local vel = self.object:getvelocity()
	local dirup = vector.normalize(vel)
	
	dirup.y = dirup.y + 1
	
	print(dump(dirup))
	
	minetest.add_particlespawner({
		amount = 5,
		time = 0,
		minpos = vector.add(pos,dirup),
		maxpos = vector.add(pos,dirup),
		minvel = vector.new(0,0,0),
		maxvel = vector.new(0,0,0),
		minacc = {x=0, y=0, z=0},
		maxacc = {x=0, y=0, z=0},
		minexptime = 5,
		maxexptime = 5,
		minsize = 1,
		maxsize = 1,
		attached = player,
		collisiondetection = true,
		vertical = false,
		texture = "treecapitator.png"
	})
	
	local dirdown = vector.new(0,-0.5,0)
	
	if rail(vector.add(pos,dirup)) then
		self.slope = "up"
		return("up")
	elseif rail(vector.add(pos,dirdown)) then
		self.slope = "down"
		return("down")
	else
		self.slope = nil
		return(nil)
	end
end

local function gravity(self,pos)
	
	if self.slope == up then
		local vel = vector.multiply(self.object:getvelocity(), 0.95)
		self.object:set_velocity(vel)
	end
	if self.slope == up then
		local vel = vector.multiply(self.object:getvelocity(), 1.05)
		self.object:set_velocity(vel)
	end

end

--make the minecart go up and down hills
local function navigate_hill(self)
	if self.slope then
		local vel = self.object:getvelocity()
		if self.slope == "up" then
		
			local yvel = 0
			if self.axis == "x" then
				yvel = math.abs(vel.x)*1.1
			end
			if self.axis == "z" then
				yvel = math.abs(vel.z)*1.1
			end
			self.object:setvelocity(vector.new(vel.x,yvel,vel.z))
		elseif self.slope == "down" then
		
			local yvel = 0
			if self.axis == "x" then
				yvel = math.abs(vel.x)*-1
			end
			if self.axis == "z" then
				yvel = math.abs(vel.z)*-1
			end
			
			self.object:setvelocity(vector.new(vel.x,yvel,vel.z))
		end
	end
end

--swap axis and speed 90 degrees
local function turn_check(self,pos)
	local axis = self.axis
	local vel = self.object:getvelocity()
	vel.x = math.abs(vel.x)
	vel.y = math.abs(vel.y)
	vel.z = math.abs(vel.z)
	
	if axis == "x" then
		if rail(vector.new(pos.x,pos.y,pos.z-1)) then
			print("-x")
			self.object:setvelocity(vector.new(0,0,vel.x*-1))
			self.axis = "z"
			snap_rail(self,pos)
			self.turn_timer = 0
			return
		elseif rail(vector.new(pos.x,pos.y,pos.z+1)) then 
			print("+x")
			self.object:setvelocity(vector.new(0,0,vel.x))
			self.axis = "z"
			snap_rail(self,pos)
			self.turn_timer = 0
			return
		end
	end
	if axis == "z" then
		if rail(vector.new(pos.x-1,pos.y,pos.z)) then
			print("-z")
			self.object:setvelocity(vector.new(vel.z*-1,0,0))
			self.axis = "x"
			snap_rail(self,pos)
			self.turn_timer = 0
			return
		elseif rail(vector.new(pos.x+1,pos.y,pos.z)) then 
			print("+z")
			self.object:setvelocity(vector.new(vel.z,0,0))
			self.axis = "x"
			snap_rail(self,pos)
			self.turn_timer = 0
			return
		end
	end
end
--try to turn
local function turn(self,pos)
	if pastcenter(self,pos) then
		if not node_forward(self,pos) and self.axis then
			turn_check(self,pos)
		end
	end
end

--the main mechanics of the minecart
local function minecart_brain(self,dtime)
	if self.turn_timer < 5 then
		self.turn_timer = self.turn_timer + dtime
	end
	local pos = self.object:getpos()
	pos.y = pos.y - 0.5

	
	if not self.axis then
		self.axis = axis(pos)
	end
	
	if newnode(self,pos) then
		snap_rail(self,pos)
	end
	--check_hill(self,pos)
	--navigate_hill(self)

	
	turn(self,pos)
	
	on_rail(self,pos)
	physical(self,pos)
	--print(self.axis)
	
	--check if falling and then fall at the same speed to go down
end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

minetest.register_entity("minecart:minecart", {
	initial_properties = {
		physical = true, -- otherwise going uphill breaks
		collisionbox = {-0.4, -0.5, -0.4, 0.4, 0.45, 0.4},--{-0.5, -0.4, -0.5, 0.5, 0.25, 0.5},
		visual = "mesh",
		mesh = "minecart.obj",
		visual_size = {x=1, y=1},
		textures = {"minecart.png"},
		automatic_face_movement_dir = 90.0,
		automatic_face_movement_max_rotation_per_sec = 600,
	},

	rider = nil,
	punched = false,
	speed = 0,
	turn_timer = 0,
	incline = nil,
	turn_timer = 5,

	on_rightclick = function(self,clicker)
		if not clicker or not clicker:is_player() then
			return
		end
		local player_name = clicker:get_player_name()
		
		if self.rider and player_name == self.rider then
			self.rider = nil
			--carts:manage_attachment(clicker, nil)
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
	
	on_activate = function(self,staticdata, dtime_s)
		self.object:set_armor_groups({immortal=1})
		if string.sub(staticdata, 1, string.len("return")) ~= "return" then
			return
		end
		local data = minetest.deserialize(staticdata)
		if type(data) ~= "table" then
			return
		end
		self.railtype = data.railtype
		if data.old_dir then
			self.old_dir = data.old_dir
		end
	end,

	get_staticdata = function(self)
		return minetest.serialize({
		})
	end,
	
	on_punch = function(self,puncher, time_from_last_punch, tool_capabilities, dir, damage)
		local obj = minetest.add_item(self.object:getpos(), "minecart:minecart")
		obj:get_luaentity().collection_timer = 2
		self.object:remove()
	end,

	--repel from players on track "push"
	push = function(self)
		if self.turn_timer > 0.3 then
			local pos = self.object:getpos()
			local radius = 1.2
			for _,object in ipairs(minetest.get_objects_inside_radius(pos, radius)) do
				if object:is_player() and object:get_player_name() ~= self.rider then
					local player_pos = object:getpos()
					pos.y = 0
					player_pos.y = 0
					
					local currentvel = self.object:getvelocity()
					local vel = vector.subtract(pos, player_pos)
					vel = vector.normalize(vel)
					local distance = vector.distance(pos,player_pos)
					distance = (radius-distance)*20
					vel = vector.multiply(vel,distance)
					local acceleration = vector.new(vel.x-currentvel.x,0,vel.z-currentvel.z)
					
					
					if self.axis == "x"	then
						self.object:add_velocity(vector.new(acceleration.x,0,0))
					elseif self.axis == "z" then
						self.object:add_velocity(vector.new(0,0,acceleration.z))
					else
						self.object:add_velocity(acceleration)
					end
					
					acceleration = vector.multiply(acceleration, -0,5)
					object:add_player_velocity(acceleration)
				end
			end
		end
	end,

	--slows the minecart down
	slowdown = function(self)
		if not self.moving == true then
			local vel = self.object:getvelocity()
			local deceleration = vector.multiply(vel, -0.01)
			self.object:add_velocity(deceleration)
		end
	end,

	--mechanics to follow rails
	ride_rail = function(self,dtime)
		minecart_brain(self,dtime)
	end,

	on_step = function(self,dtime)
		self.push(self)
		self.slowdown(self)
		self.ride_rail(self,dtime)
	end,
	
})

minetest.register_craftitem("minecart:minecart", {
	description = "Minecart",
	inventory_image = "minecartitem.png",
	wield_image = "minecartitem.png",
	on_place = function(itemstack, placer, pointed_thing)
		if not pointed_thing.type == "node" then
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
