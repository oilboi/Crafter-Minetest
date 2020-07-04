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
				local velocity = 1-vector.distance(vector.new(pos.x,0,0),vector.new(pos2.x,0,0))
				local dir = vector.direction(vector.new(pos2.x,0,0),vector.new(pos.x,0,0))
				self.object:add_velocity(dir)
			elseif self.axis_lock == "z" then
				local velocity = 1-vector.distance(vector.new(0,0,pos.z),vector.new(0,0,pos2.z))
				local dir = vector.direction(vector.new(0,0,pos2.z),vector.new(0,0,pos.z))
				self.object:add_velocity(dir)
			end
			return
		end
	end
end

local minecart = {}

minecart.on_step = function(self,dtime)
	local pos = vector.round(self.object:get_pos())
	if not self.axis_lock then
		local possible_dirs = create_axis(pos)
		for _,dir in pairs(possible_dirs) do
			if dir.x ~=0 then
				self.axis_lock = "x"
				break
			elseif dir.z ~= 0 then
				self.axis_lock = "z"
				break
			end
		end
	else
		collision_detect(self)
	end
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
