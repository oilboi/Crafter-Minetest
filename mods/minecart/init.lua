local pool = {}

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
				local velocity = (1-vector.distance(vector.new(pos.x,0,0),vector.new(pos2.x,0,0)))/50
				local dir = vector.direction(vector.new(pos2.x,0,0),vector.new(pos.x,0,0))
				local new_vel = vector.multiply(dir,velocity)
				self.velocity = new_vel
				self.dir = dir
			elseif self.axis_lock == "z" then
				local velocity = (1-vector.distance(vector.new(0,0,pos.z),vector.new(0,0,pos2.z)))/50
				local dir = vector.direction(vector.new(0,0,pos2.z),vector.new(0,0,pos.z))
				self.velocity = vector.multiply(dir,velocity)
				self.dir = dir
			end
			return
		end
	end
end

local function direction_snap(self)
	local dir = self.dir
	local yaw = minetest.dir_to_yaw(dir)
	self.object:set_rotation(vector.new(0,yaw,0))
end

local function turn_snap(pos,self,dir,dir2)
	if dir.x ~= 0 and dir2.z ~= 0 then
		local inertia = math.abs(self.velocity.x)
		self.velocity = vector.multiply(dir2,inertia)
		self.dir = dir2
		self.axis_lock = "z"
		self.object:set_pos(pos)
		direction_snap(self)
		return(true)
	elseif dir.z ~= 0 and dir2.x ~= 0 then
		local inertia = math.abs(self.velocity.z)
		self.velocity = vector.multiply(dir2,inertia)
		self.dir = dir2
		self.axis_lock = "x"
		self.object:set_pos(pos)
		direction_snap(self)
		return(true)
	end
end

local function rail_brain(self,pos)
	if not self.dir then return end

	--if self.dir then print(dump(self.dir)) end

	local pos2 = self.object:get_pos()

	local dir = self.dir

	local triggered = false

	if dir.x < 0 and pos2.x < pos.x then
		triggered = true
	elseif dir.x > 0 and pos2.x > pos.x then
		triggered = true
	elseif dir.z < 0 and pos2.z < pos.z then
		triggered = true
	elseif dir.z > 0 and pos2.z > pos.z then
		triggered = true
	end

	--print(dump(dir))
	if triggered and not pool[minetest.hash_node_position(vector.add(pos,dir))] then
		local possible_dirs = create_axis(pos)
		if table.getn(possible_dirs) == 0 then
			--print("train fails")
			--stop slow down become physical, something
		else
			for _,dir2 in pairs(possible_dirs) do
				if turn_snap(pos,self,dir,dir2) then
					return
				end
			end
		end
	end
end




local minecart = {}

minecart.on_step = function(self,dtime)
	local float_pos = self.object:get_pos()
	local pos = vector.round(float_pos)

	if self.velocity then
		local new_vel = dtime*1000
		local test = vector.multiply(self.velocity,new_vel)

		if test.x > 0.5 then
			test.x = 0.5
		elseif test.x < -0.5 then
			test.x = -0.5
		end
		if test.z > 0.5 then
			test.z = 0.5
		elseif test.z < -0.5 then
			test.z = -0.5
		end
		self.object:move_to(vector.add(float_pos,test))
	end

	if not self.axis_lock then
		local possible_dirs = create_axis(pos)
		for _,dir in pairs(possible_dirs) do
			if dir.x ~=0 then
				self.axis_lock = "x"
				self.dir = vector.new(1,0,0)
				direction_snap(self)
				break
			elseif dir.z ~= 0 then
				self.axis_lock = "z"
				self.dir = vector.new(0,0,1)
				direction_snap(self)
				break
			end
		end
	else
		collision_detect(self)
		rail_brain(self,pos)
	end
	self.old_pos = float_pos
end

minecart.on_rightclick = function(self,clicker)
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
		print("buildin dat cash")
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
