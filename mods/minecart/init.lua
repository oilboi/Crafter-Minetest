local pool = {}

local player_pool = {}


local dirs = {
	{x= 1,y= 0,z= 0},
	{x=-1,y= 0,z= 0},

	{x= 1,y= 1,z= 0}, 
	{x=-1,y= 1,z= 0},

	{x= 1,y=-1,z= 0},
	{x=-1,y=-1,z= 0},

	{x= 0,y= 0,z= 1},
	{x= 0,y= 0,z=-1},

	{x= 0,y= 1,z= 1},
	{x= 0,y= 1,z=-1},

	{x= 0,y=-1,z= 1},
	{x= 0,y=-1,z=-1},
}

local axis_order = {

}
local function data_injection(pos,data)
	if data then
		pool[minetest.hash_node_position(pos)] = true
	else
		pool[minetest.hash_node_position(pos)] = nil
	end
end


local function create_axis(pos)
	local possible_dirs = {}
	for _,dir in pairs(dirs) do
		local pos2 = vector.add(pos,dir)
		if pool[minetest.hash_node_position(pos2)] then
			table.insert(possible_dirs,dir)
		end
	end
	return(possible_dirs)
end

local function collision_detect(self)
	if not self.axis_lock then return end
	local pos = self.object:get_pos()
	for _,object in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
		if object:is_player() then
			local pos2 = object:get_pos()
			if self.axis_lock == "x" then

				local velocity = (1-vector.distance(vector.new(pos.x,0,0),vector.new(pos2.x,0,0)))
				local dir = vector.direction(vector.new(pos2.x,0,0),vector.new(pos.x,0,0))
				local new_vel = vector.multiply(dir,velocity)
				self.object:add_velocity(new_vel)
				self.dir = dir
			elseif self.axis_lock == "z" then
				local velocity = (1-vector.distance(vector.new(0,0,pos.z),vector.new(0,0,pos2.z)))
				local dir = vector.direction(vector.new(0,0,pos2.z),vector.new(0,0,pos.z))
				local new_vel = vector.multiply(dir,velocity)
				self.object:add_velocity(new_vel)
				self.dir = dir
			end
			return
		end
	end
end

local function direction_snap(self)
	local dir = self.dir
	local pitch = 0
	if dir.y == 1 then pitch = math.pi/4 end
	if dir.y == -1 then pitch = -math.pi/4 end
	local yaw = minetest.dir_to_yaw(dir)
	self.object:set_rotation(vector.new(pitch,yaw,0))
end

local function turn_snap(pos,self,dir,dir2)
	if self.axis_lock == "x" then
		if dir.x ~= 0 and dir2.z ~= 0 then
			local velocity = self.object:get_velocity()
			local inertia = math.abs(velocity.x)
			self.object:set_velocity(vector.multiply(dir2,inertia))
			self.dir = dir2
			self.axis_lock = "z"
			self.object:set_pos(pos)
			direction_snap(self)
			return(true)
		end
	end
	if self.axis_lock == "z" then
		if dir.z ~= 0 and dir2.x ~= 0 then
			local velocity = self.object:get_velocity()
			local inertia = math.abs(velocity.z)
			self.object:set_velocity(vector.multiply(dir2,inertia))
			self.dir = dir2
			self.axis_lock = "x"
			self.object:set_pos(pos)
			direction_snap(self)
			return(true)
		end
	end
	return(false)
end

local function climb_snap(pos,self,dir,dir2)
	if self.axis_lock == "x" then
		if dir.x == dir2.x and dir2.y ~= 0 then
			local velocity = self.object:get_velocity()
			local inertia = math.abs(velocity.x)
			self.object:set_velocity(vector.multiply(dir2,inertia))
			self.dir = dir2
			self.axis_lock = "x"
			self.object:set_pos(pos)
			direction_snap(self)
			return(true)
		end
	end
	if self.axis_lock == "z" then
		if dir.z == dir2.z and dir2.y ~= 0 then
			local velocity = self.object:get_velocity()
			local inertia = math.abs(velocity.z)
			self.object:set_velocity(vector.multiply(dir2,inertia))
			self.dir = dir2
			self.axis_lock = "z"
			self.object:set_pos(pos)
			direction_snap(self)
			return(true)
		end
	end
	return(false)
end

local function straight_snap(pos,self,dir)
	if self.axis_lock == "x" then
		if dir.x ~= 0 and pool[minetest.hash_node_position(vector.add(pos,vector.new(dir.x,0,0)))] then
			local velocity = self.object:get_velocity()
			self.object:set_velocity(vector.new(velocity.x,0,0))
			self.dir = vector.new(dir.x,0,0)
			self.axis_lock = "x"
			self.object:set_pos(pos)
			direction_snap(self)
			return(true)
		end
	end
	if self.axis_lock == "z" then
		if dir.z ~= 0 and pool[minetest.hash_node_position(vector.add(pos,vector.new(0,0,dir.z)))] then
			local velocity = self.object:get_velocity()
			self.object:set_velocity(vector.new(0,0,velocity.z))
			self.dir = vector.new(0,0,dir.z)
			self.axis_lock = "z"
			self.object:set_pos(pos)
			direction_snap(self)
			return(true)
		end
	end
	return(false)
end

local function rail_brain(self,pos)
	if not self.dir then return end

	--if self.dir then print(dump(self.dir)) end

	local pos2 = self.object:get_pos()

	local dir = self.dir

	local triggered = false

	if     dir.x < 0 and pos2.x < pos.x then
		triggered = true
	elseif dir.x > 0 and pos2.x > pos.x then
		triggered = true
	elseif dir.z < 0 and pos2.z < pos.z then
		triggered = true
	elseif dir.z > 0 and pos2.z > pos.z then
		triggered = true
	end

	if triggered and not pool[minetest.hash_node_position(vector.add(pos,dir))] then

		if straight_snap(pos,self,dir) then
			return
		end

		local possible_dirs = create_axis(pos)
		
		if table.getn(possible_dirs) == 0 then
			--print("train fails")
			--stop slow down become physical, something
		else
			for _,dir2 in pairs(possible_dirs) do
				if climb_snap(pos,self,dir,dir2) then
					return
				end
			end
			
			for _,dir2 in pairs(possible_dirs) do
				if turn_snap(pos,self,dir,dir2) then
					return
				end
			end
		end
	end
end


local function coupling_logic(self)
	
	if not self.axis_lock then return end

	if not self.coupler1 then return end

	if not self.dir.y == 0 then print("failing") return end

	local pos = self.object:get_pos()
	
	local pos2 = self.coupler1:get_pos()

	if self.axis_lock == "x" then
		--local velocity = self.object:get_velocity()

		local distance = 1-vector.distance(pos,pos2)		

		local dir = vector.direction(vector.new(pos2.x,0,0),vector.new(pos.x,0,0))

		local new_vel = vector.multiply(dir,distance)
		self.object:add_velocity(new_vel)
		--self.dir = dir
	--[[
	elseif self.axis_lock == "z" then
		local velocity = self.object:get_velocity()
		local velocity = (1-vector.distance(pos,pos2))
		local dir = vector.direction(vector.new(0,0,pos2.z),vector.new(0,0,pos.z))
		local new_vel = vector.multiply(dir,velocity)
		self.object:add_velocity(new_vel)
		--self.dir = dir
		]]--
	end
	return
end


local minecart = {}

minecart.on_step = function(self,dtime)
	local float_pos = self.object:get_pos()
	local pos = vector.round(float_pos)

	--if self.velocity then
		--local new_vel = dtime*1000
		local test = self.object:get_velocity()--vector.multiply(self.velocity,new_vel)

		if test.x > 10 then
			test.x = 10
			print("slowing down 1")
		elseif test.x < -10 then
			test.x = -10
			print("slowing down 2")
		end
		if test.z > 10 then
			test.z = 10
			print("slowing down 3")
		elseif test.z < -10 then
			test.z = -10
			print("slowing down 4")
			
		end
		self.object:set_velocity(test)
		--self.object:move_to(vector.add(float_pos,test))
	--end

	if not self.axis_lock then
		local possible_dirs = create_axis(pos)
		for _,dir in pairs(possible_dirs) do
			if dir.x ~=0 then
				self.axis_lock = "x"
				self.dir = vector.new(1,0,0)
				--self.velocity = vector.new(0,0,0)
				direction_snap(self)
				break
			elseif dir.z ~= 0 then
				self.axis_lock = "z"
				self.dir = vector.new(0,0,1)
				--self.velocity = vector.new(0,0,0)
				direction_snap(self)
				break
			end
		end
	else

		collision_detect(self)

		coupling_logic(self)

		rail_brain(self,pos)
	end
	self.old_pos = float_pos
end

minecart.on_rightclick = function(self,clicker)
	local name = clicker:get_player_name()
	if not pool[name] then
		pool[name] = self.object
	else
		self.coupler1 = pool[name]
		--pool[name]:get_luaentity().coupler1 = self.object
		pool[name] = nil
		print("coupled")
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
	self.old_pos = self.object:get_pos()
	self.velocity = vector.new(0,0,0)
end

minecart.get_staticdata = function(self)
	return minetest.serialize({
	})
end



minecart.initial_properties = {
	physical = false, -- otherwise going uphill breaks
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 0.45, 0.4},--{-0.5, -0.4, -0.5, 0.5, 0.25, 0.5},
	visual = "mesh",
	mesh = "minecart.x",
	visual_size = {x=1, y=1},
	textures = {"minecart.png"},
}


minecart.on_punch = function(self,puncher, time_from_last_punch, tool_capabilities, dir, damage)
	--local obj = minetest.add_item(self.object:getpos(), "minecart:minecart")
	--self.object:remove()
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





minetest.register_node("minecart:rail",{
	description = "Rail",
	wield_image = "rail.png",
	tiles = {
		"rail.png", "railcurve.png",
		"railt.png", "railcross.png"
	},
	drawtype = "raillike",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	node_placement_prediction = "",
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
	sounds = main.stoneSound(),
	after_place_node = function(pos)
		data_injection(pos,true)
	end,
	after_destruct = function(pos)
		data_injection(pos)
	end,
	groups={stone=1,wood=1,rail=1,attached_node=1},
})


minetest.register_lbm({
	name = "minecart:rail",
	nodenames = {"minecart:rail"},
	run_at_every_load = true,
	action = function(pos)
		data_injection(pos,true)
		--print("buildin dat cashay")
	end,
})

minetest.register_craft({
	output = "minecart:rail 32",
	recipe = {
		{"main:iron","","main:iron"},
		{"main:iron","main:stick","main:iron"},
		{"main:iron","","main:iron"}
	}
})
