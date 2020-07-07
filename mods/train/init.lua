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

local function coupling_particles(pos,truth)
	local color = "red"
	if truth then
		color = "green"
	end

	minetest.add_particlespawner({
		amount = 15,
		time = 0.001,
		minpos = pos,
		maxpos = pos,
		minvel = vector.new(-10,-10,-10),
		maxvel = vector.new(10,10,10),
		minacc = {x=0, y=0, z=0},
		maxacc = {x=0, y=0, z=0},
		minexptime = 1.1,
		maxexptime = 1.5,
		minsize = 1,
		maxsize = 2,
		collisiondetection = false,
		collision_removal = false,
		vertical = false,
		texture = "couple_particle.png^[colorize:"..color..":200",
		glow = 14,
	})
end

local function data_injection(pos,data)
	if data then
		pool[minetest.hash_node_position(pos)] = true
	else
		pool[minetest.hash_node_position(pos)] = nil
	end
end

local function speed_limiter(self,speed)
	local test = self.object:get_velocity()--vector.multiply(self.velocity,new_vel)

	if test.x > speed then
		test.x = speed
	elseif test.x < -speed then
		test.x = -speed
	end
	if test.z > speed then
		test.z = speed
	elseif test.z < -speed then
		test.z = -speed		
	end
	self.object:set_velocity(test)
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

				local velocity = (1-vector.distance(vector.new(pos.x,0,0),vector.new(pos2.x,0,0)))*5
				local dir = vector.direction(vector.new(pos2.x,0,0),vector.new(pos.x,0,0))
				local new_vel = vector.multiply(dir,velocity)
				self.object:add_velocity(new_vel)
				self.dir = dir
			elseif self.axis_lock == "z" then
				local velocity = (1-vector.distance(vector.new(0,0,pos.z),vector.new(0,0,pos2.z)))*5
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

	if self.driver then
		self.driver:set_look_vertical(-pitch)
		self.driver:set_look_horizontal(yaw)
	end
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


local function coupling_logic(self)
	
	if not self.axis_lock then return end

	if not self.coupler1 then return end

	if self.dir.y ~= 0 then return end

	local pos = self.object:get_pos()
	
	local pos2 = self.coupler1:get_pos()

	local coupler_goal = self.coupler1:get_luaentity().coupler_distance

	local coupler_velocity = self.coupler1:get_velocity()

	if self.axis_lock == "x" then
		local velocity_real = self.object:get_velocity()
		local distance = vector.distance(pos,pos2)
		local new_vel = vector.new(0,0,0)
		if distance > coupler_goal then
			local velocity = (distance-coupler_goal)*5
			local dir = vector.direction(vector.new(pos.x,0,0),vector.new(pos2.x,0,0))
			self.dir = dir
			new_vel = vector.multiply(dir,velocity)
		else
			--if vector.equals(coupler_velocity,vector.new(0,0,0)) then
				--new_vel = vector.multiply(velocity_real,-1)
			if distance > coupler_goal-0.2 then
				local c_vel = vector.distance(vector.new(0,0,0),coupler_velocity)
				local a_vel = vector.distance(vector.new(0,0,0),velocity_real)
				local d_vel = a_vel-c_vel
				if d_vel < 0 then
					d_vel = 0
				end
				new_vel = vector.multiply(self.dir,d_vel)
			else
				new_vel = vector.multiply(velocity_real,-1)
			end
		end
		self.object:add_velocity(new_vel)
	elseif self.axis_lock == "z" then
		local velocity_real = self.object:get_velocity()
		local distance = vector.distance(pos,pos2)
		local new_vel = vector.new(0,0,0)
		if distance > coupler_goal then
			local velocity = (distance-coupler_goal)*5
			local dir = vector.direction(vector.new(0,0,pos.z),vector.new(0,0,pos2.z))
			self.dir = dir
			new_vel = vector.multiply(dir,velocity)
		else
			--if vector.equals(coupler_velocity,vector.new(0,0,0)) then
				--new_vel = vector.multiply(velocity_real,-1)
			if distance > coupler_goal-0.2 then
				local c_vel = vector.distance(vector.new(0,0,0),coupler_velocity)
				local a_vel = vector.distance(vector.new(0,0,0),velocity_real)
				local d_vel = a_vel-c_vel
				if d_vel < 0 then
					d_vel = 0
				end
				new_vel = vector.multiply(self.dir,d_vel)
			else
				new_vel = vector.multiply(velocity_real,-1)
			end
		end
		self.object:add_velocity(new_vel)
	end

	return
end


local function rail_brain(self,pos)

	if not self.dir then self.dir = vector.new(0,0,0) end

	local pos2 = self.object:get_pos()

	local dir = self.dir

	speed_limiter(self,6)

	if not pool[minetest.hash_node_position(vector.add(pos,dir))] then

		if straight_snap(pos,self,dir) then
			return
		end

		local possible_dirs = create_axis(pos)

		if table.getn(possible_dirs) == 0 then
			--stop slow down become physical
		else
			for _,dir2 in pairs(possible_dirs) do
				if turn_snap(pos,self,dir,dir2) then
					return
				end
				if climb_snap(pos,self,dir,dir2) then
					return
				end
			end
		end
	else
		if self.is_car then
			coupling_logic(self)
		end
	end

end


--[[
 █████╗ ██████╗ ██╗    ██████╗ ███████╗ ██████╗ ██╗███╗   ██╗
██╔══██╗██╔══██╗██║    ██╔══██╗██╔════╝██╔════╝ ██║████╗  ██║
███████║██████╔╝██║    ██████╔╝█████╗  ██║  ███╗██║██╔██╗ ██║
██╔══██║██╔═══╝ ██║    ██╔══██╗██╔══╝  ██║   ██║██║██║╚██╗██║
██║  ██║██║     ██║    ██████╔╝███████╗╚██████╔╝██║██║ ╚████║
╚═╝  ╚═╝╚═╝     ╚═╝    ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝
]]--


function register_train(name,data)
local train = {}

train.power            = data.power
train.coupler_distance = data.coupler_distance
train.is_car           = data.is_car
train.is_engine        = data.is_engine
train.max_speed        = data.max_speed
train.driver           = nil

train.initial_properties = {
	physical = false, -- otherwise going uphill breaks
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 0.45, 0.4},
	visual = "mesh",
	mesh = data.mesh,
	visual_size = {x=1, y=1},
	textures = {data.texture},
}


train.on_step = function(self,dtime)
	if dtime > 0.1 then
		self.object:set_pos(self.old_pos)
	end
	local pos = vector.round(self.object:get_pos())
	if not self.axis_lock then
		local possible_dirs = create_axis(pos)
		for _,dir in pairs(possible_dirs) do
			if dir.x ~=0 then
				self.axis_lock = "x"
				self.dir = dir
				direction_snap(self)
				break
			elseif dir.z ~= 0 then
				self.axis_lock = "z"
				self.dir = dir
				direction_snap(self)
				break
			end
		end
	else
		rail_brain(self,pos)
		--collision_detect(self)
	end
	self.old_pos = self.object:get_pos()
end




train.on_punch = function(self, puncher)
	if not puncher:get_wielded_item():get_name() == "train:wrench" then
		return
	end

	if self.is_engine and puncher:get_player_control().sneak then
		if vector.equals(self.object:get_velocity(),vector.new(0,0,0)) then
			if self.dir.y == 0 then
				self.dir = vector.multiply(self.dir,-1)
				direction_snap(self)
				minetest.sound_play("wrench",{
					object = self.object,
					gain = 1.0,
					max_hear_distance = 64,
				})
			end
		end
		return
	end

	if self.is_engine then
		self.object:set_velocity(vector.multiply(self.dir,self.max_speed))
		return
	end

	if self.coupler1 then
		self.coupler1:get_luaentity().coupler2 = nil
		self.coupler1 = nil
	end

	if self.coupler2 then
		self.coupler2:get_luaentity().coupler1 = nil
		self.coupler2 = nil
	end

end


train.on_rightclick = function(self,clicker)
	--[[
	if clicker:get_wielded_item():get_name() == "utility:furnace" then
		local obj = minetest.add_entity(pos, "train:furnace")
		obj:set_attach(self.object,"",vector.new(0,0,0),vector.new(0,0,0))
		minetest.sound_play("wrench",{
			object = self.object,
			gain = 1.0,
			max_hear_distance = 64,
		})
		coupling_particles(pos,true)
		self.furnace = true
		return
	end
	]]--

	if clicker:get_wielded_item():get_name() ~= "train:wrench" then
		if self.is_engine then
			if not self.driver then
				print("jump on in")
				clicker:set_attach(self.object, "", data.body_pos, data.body_rotation)
				clicker:set_eye_offset(data.eye_offset,{x=0,y=0,z=0})
				player_is_attached(clicker,true)
				set_player_animation(clicker,"stand",0)
				local rotation = self.object:get_rotation()
				clicker:set_look_vertical(0)
				clicker:set_look_horizontal(rotation.y)
				self.object:set_velocity(vector.multiply(self.dir,self.max_speed))
				self.driver = clicker
			elseif clicker == self.driver then
				print("jumpin off!")
				clicker:set_detach()
				clicker:set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})
				player_is_attached(clicker,false)
				set_player_animation(clicker,"stand",0)
				self.object:set_velocity(vector.new(0,0,0))
				self.driver = nil
			end
			return
		end
		return
	end

	local pos = self.object:get_pos()

	local name = clicker:get_player_name()
	if not pool[name] then
		if not self.coupler2 then
			pool[name] = self.object
			minetest.sound_play("wrench",{
				object = self.object,
				gain = 1.0,
				max_hear_distance = 64,
			})
			coupling_particles(pos,true)
		else
			minetest.sound_play("wrench",{
				object = self.object,
				gain = 1.0,
				max_hear_distance = 64,
				pitch = 0.7,
			})
			coupling_particles(pos,false)
		end
	else
		if not self.is_engine and pool[name] ~= self.object and not (pool[name]:get_luaentity().coupler1 and pool[name]:get_luaentity().coupler1 == self.object or self.coupler2) then
			self.coupler1 = pool[name]
			pool[name]:get_luaentity().coupler2 = self.object
			minetest.sound_play("wrench",{
				object = self.object,
				gain = 1.0,
				max_hear_distance = 64,
			})
			coupling_particles(pos,true)
		else
			minetest.sound_play("wrench",{
				object = self.object,
				gain = 1.0,
				max_hear_distance = 64,
				pitch = 0.7,
			})
			coupling_particles(pos,false)
		end
		pool[name] = nil
	end
end

--get old data
train.on_activate = function(self,staticdata, dtime_s)
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

train.get_staticdata = function(self)
	return minetest.serialize({
	})
end

minetest.register_entity(name, train)

end

--[[
███████╗███╗   ██╗██████╗ 
██╔════╝████╗  ██║██╔══██╗
█████╗  ██╔██╗ ██║██║  ██║
██╔══╝  ██║╚██╗██║██║  ██║
███████╗██║ ╚████║██████╔╝
╚══════╝╚═╝  ╚═══╝╚═════╝ 
]]--




register_train("train:steam_train",{
	mesh = "steam_train.b3d",
	texture = "steam_train.png",
	is_engine = true,
	power = 6,
	max_speed = 6,
	coupler_distance = 3,
	body_pos = vector.new(0,0,-15),
	body_rotation = vector.new(0,0,0),
	eye_offset = vector.new(6,-1,-10)
})

register_train("train:steam_train_small",{
	mesh = "steam_train_small.b3d",
	texture = "steam_train_small.png",
	is_engine = true,
	power = 6,
	max_speed = 6,
	coupler_distance = 3,
	body_pos = vector.new(0,0,-15),
	body_rotation = vector.new(0,0,0),
	eye_offset = vector.new(6,-1,-10)
})


register_train("train:minecart",{
	mesh = "minecart.x",
	texture = "minecart.png",
	--is_engine = true,
	is_car = true,
	--power = 6,
	max_speed = 6,
	coupler_distance = 1.3,
	--body_pos = vector.new(0,0,-15),
	--body_rotation = vector.new(0,0,0),
	--eye_offset = vector.new(6,-1,-10)
})



minetest.register_craftitem("train:train", {
	description = "Steam Train",
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
			minetest.add_entity(pointed_thing.under, "train:steam_train")
		else
			return
		end

		itemstack:take_item()

		return itemstack
	end,
})

minetest.register_craft({
	output = "train:minecart",
	recipe = {
		{"main:iron", "main:iron", "main:iron"},
		{"main:iron", "main:iron", "main:iron"},
	},
})


minetest.register_craftitem("train:minecart", {
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
			minetest.add_entity(pointed_thing.under, "train:minecart")
		else
			return
		end

		itemstack:take_item()

		return itemstack
	end,
})

minetest.register_craft({
	output = "train:train",
	recipe = {
		{"main:iron", "", "main:iron"},
		{"main:iron", "main:iron", "main:iron"},
	},
})



minetest.register_node("train:rail",{
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
	name = "train:rail",
	nodenames = {"train:rail"},
	run_at_every_load = true,
	action = function(pos)
		data_injection(pos,true)
	end,
})

minetest.register_craft({
	output = "train:rail 32",
	recipe = {
		{"main:iron","","main:iron"},
		{"main:iron","main:stick","main:iron"},
		{"main:iron","","main:iron"}
	}
})


minetest.register_food("train:wrench",{
	description = "Train Wrench",
	texture = "wrench.png",
})

minetest.register_craft({
	output = "train:wrench",
	recipe = {
		{"main:iron", "", "main:iron"},
		{"main:iron", "main:lapis", "main:iron"},
		{"", "main:lapis", ""}
	}
})



minetest.register_entity("train:furnace", {
	initial_properties = {
		visual = "wielditem",
		visual_size = {x = 0.6, y = 0.6},
		textures = {},
		physical = true,
		is_visible = false,
		collide_with_objects = false,
		pointable=false,
		collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	},
	set_node = function(self)
		self.object:set_properties({
			is_visible = true,
			textures = {"utility:furnace"},
		})
	end,


	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal = 1})

		self:set_node()
	end,
})

local steam_check_dirs = {
	{x= 1,y= 0,z= 0},
	{x=-1,y= 0,z= 0},
	{x= 0,y= 0,z= 1},
	{x= 0,y= 0,z=-1},
}
local buffer_pool = {}
local function do_craft_effects(pos)
	local hash_pos = minetest.hash_node_position(pos)

	if buffer_pool[hash_pos] then return end

	buffer_pool[hash_pos] = true

	minetest.sound_play("steam_whistle_1",{pos=pos,gain=3,max_hear_distance=128})
	minetest.add_particlespawner({
		amount = 275,
		time = 1.3,
		minpos = vector.new(pos.x-0.1,pos.y+0.5,pos.z-0.1),
		maxpos = vector.new(pos.x+0.1,pos.y+0.5,pos.z+0.1),
		minvel = vector.new(-0.5,3,-0.5),
		maxvel = vector.new(0.5,5,0.5),
		minacc = {x=0, y=3, z=0},
		maxacc = {x=0, y=5, z=0},
		minexptime = 1.1,
		maxexptime = 1.5,
		minsize = 1,
		maxsize = 2,
		collisiondetection = false,
		collision_removal = false,
		vertical = false,
		texture = "smoke.png",
	})

	minetest.after(1.3, function()
		for _,dir in pairs(steam_check_dirs) do
			local n_pos = vector.add(pos,dir)
			local node2 = minetest.get_node(n_pos).name
			if not minetest.get_nodedef(node2, "walkable") then
				local dir_mod = vector.multiply(dir,0.5)
				local x_min
				local x_max
				local z_min
				local z_max
				if dir.z == 0 then
					x_min = dir_mod.x
					x_max = dir_mod.x
					z_min = -0.2
					z_max = 0.2
				elseif dir.x == 0 then
					x_min = -0.2
					x_max = 0.2
					z_min = dir_mod.z
					z_max = dir_mod.z
				end

				local p_min = vector.new(pos.x+x_min,pos.y-0.2,pos.z+z_min)
				local p_max = vector.new(pos.x+x_max,pos.y+0.2,pos.z+z_max)

				local v_min = vector.new(dir_mod.x,0.2,dir_mod.z)
				local v_max = vector.new(dir_mod.x*2,0.3,dir_mod.z*2)

				minetest.add_particlespawner({
					amount = 200,
					time = 1.95,
					minpos = p_min,
					maxpos = p_max,
					minvel = v_min,
					maxvel = v_max,
					minacc = vector.new(0,1,0),
					maxacc = vector.new(0,3,0),
					minexptime = 1.1,
					maxexptime = 1.5,
					minsize = 1,
					maxsize = 2,
					collisiondetection = false,
					collision_removal = false,
					vertical = false,
					texture = "smoke.png^[colorize:white:255",
				})
				
			end
		end
		minetest.sound_play("steam_release",{pos=pos,gain=1,max_hear_distance=128})
		minetest.after(1, function()
			buffer_pool[hash_pos] = nil
		end)
	end)
end

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if minetest.registered_items[itemstack:get_name()].mod_origin == "train" then
		local pos = player:get_pos()
		pos.y = pos.y + 1.625
		local look_dir = player:get_look_dir()
		look_dir = vector.multiply(look_dir,4)
		local pos2 = vector.add(pos,look_dir)
		local ray = minetest.raycast(pos, pos2, false, true)		
		if ray then
			for pointed_thing in ray do
				if pointed_thing then
					if minetest.get_node(pointed_thing.under).name == "craftingtable:craftingtable" then
						do_craft_effects(pointed_thing.under)
					end
				end
			end
		end
	end
end)