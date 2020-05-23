treecaptitator = {}

local dropper = {"main:leaves","main:stick","main:apple"}

-- Leafdecay
local function leafdecay_after_destruct(pos, oldnode, def)
	for _, v in pairs(minetest.find_nodes_in_area(vector.subtract(pos, def.radius),
			vector.add(pos, def.radius), def.leaves)) do
		local node = minetest.get_node(v)
		local timer = minetest.get_node_timer(v)
		if node.param2 ~= 1 and not timer:is_started() then
			timer:start(math.random()+math.random()+math.random())
		end
	end
end

local function leafdecay_on_timer(pos, def)
	if minetest.find_node_near(pos, def.radius, def.trunks) then
		return false
	end

	local node = minetest.get_node(pos)
	local drops = minetest.get_node_drops(node.name)
	for _, item in ipairs(drops) do
		local is_leaf
		for _, v in pairs(def.leaves) do
			if v == item then
				is_leaf = true
			end
		end
		if minetest.get_item_group(item, "leafdecay_drop") ~= 0 or not is_leaf then
			minetest.add_item({
				x = pos.x - 0.5 + math.random(),
				y = pos.y - 0.5 + math.random(),
				z = pos.z - 0.5 + math.random(),
			}, item)
		end
	end
	
	minetest.remove_node(pos)
	minetest.check_for_falling(pos)
	
	minetest.add_particlespawner({
		amount = 20,
		time = 0.0001,
		minpos = {x=pos.x-0.5, y=pos.y-0.5, z=pos.z-0.5},
		maxpos = {x=pos.x+0.5, y=pos.y+0.5, z=pos.z+0.5},
		minvel = vector.new(-1,0,-1),
		maxvel = vector.new(1,0,1),
		minacc = {x=0, y=-9.81, z=0},
		maxacc = {x=0, y=-9.81, z=0},
		minexptime = 0.5,
		maxexptime = 1.5,
		minsize = 0,
		maxsize = 0,
		collisiondetection = true,
		vertical = false,
		node = {name= node.name},
	})
	minetest.sound_play("leaves", {pos=pos, gain = 0.2, max_hear_distance = 60,pitch = math.random(70,100)/100})
	--random drops - remove this for now
	--if math.random() > 0.75 then
		--local obj = minetest.add_item(pos,dropper[math.random(1,3)])
	--end
end

function treecaptitator.register_leafdecay(def)
	assert(def.leaves)
	assert(def.trunks)
	assert(def.radius)
	for _, v in pairs(def.trunks) do
		minetest.override_item(v, {
			after_destruct = function(pos, oldnode)
				leafdecay_after_destruct(pos, oldnode, def)
			end,
		})
	end
	for _, v in pairs(def.leaves) do
		minetest.override_item(v, {
			on_timer = function(pos)
				leafdecay_on_timer(pos, def)
			end,
		})
	end
end

----------------------------- registration
treecaptitator.register_leafdecay({
	trunks = {"main:tree"},
	leaves = {"main:leaves"},
	radius = 2,
})

--[[
bvav_settings = {}
bvav_settings.attach_scaling = 30
bvav_settings.scaling = 0.667


minetest.register_entity("treecapitator:tree_element", {
	initial_properties = {
		physical = true,
		collide_with_objects = false,
		pointable = false,
		collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
		visual = "wielditem",
		textures = {},
		automatic_face_movement_dir = 0.0,
		visual_size = {x=bvav_settings.scaling, y=bvav_settings.scaling}
	},

	node = {},

	set_node = function(self, node)
		self.node = node
		local prop = {
			is_visible = true,
			textures = {node.name},
			visual_size = {x=bvav_settings.scaling, y=bvav_settings.scaling}
		}
		self.object:set_properties(prop)
	end,

	get_staticdata = function(self)
		return self.node.name
	end,

	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal=1})
		if staticdata then
			self:set_node({name=staticdata})
		end
		minetest.after(0,function()
			
			if self.parent ~= nil and self.relative ~= nil then
				self.object:set_attach(self.parent, "", {x=self.relative.x,y=self.relative.y,z=self.relative.z}, {x=0,y=0,z=0})
				self.object:set_properties({visual_size = {x=bvav_settings.scaling*3, y=bvav_settings.scaling*3}})
				--self.object:set_properties({})
			else
				--this fixes issues with scaling
				self.object:set_properties({visual_size = {x=bvav_settings.scaling, y=bvav_settings.scaling}})

			end
		end)
	end,
	rotation = vector.new(0,0,0),
	on_step = function(self, dtime)
		if self.rotator and self.rotate_dir then
			local current_rot = self.object:get_rotation()
			
			if math.abs(current_rot.x) > math.pi/2 or math.abs(current_rot.z) > math.pi/2 then
				for i = 1,self.tree do
					local pos = self.object:get_pos()
					minetest.throw_item(pos,{name="main:tree"})
				end
				for i = 1,self.leaves do
					local pos = self.object:get_pos()
					minetest.throw_item(pos,{name="main:leaves"})
				end
				minetest.sound_play("tree_thud",{pos=self.object:get_pos()})
				self.object:remove()
			end
			
			if self.rotate_dir.x ~= 0 then
				current_rot.x = current_rot.x + (dtime/(self.rotate_dir.x*2.82))
			elseif self.rotate_dir.z ~= 0 then
				current_rot.z = current_rot.z + (dtime/(self.rotate_dir.z*2.82))
			end
			self.object:set_rotation(current_rot)
		else
			if not self.parent or not self.parent:get_luaentity() then
				self.object:remove()
			end
		end
	end,
})


function spawn_bvav_element(p, node)
	local obj = core.add_entity(p, "treecapitator:tree_element")
	obj:get_luaentity():set_node(node)
	return obj
end


local random_item_table = {"main:dirt","main:sand","main:glass","main:water","main:grass","main:wood"}
function bvav_create_vessel(pos,dir)
	local parent
	local base_y = 0
	local top_y = 0
	--analyze
	for y = 0,-4,-1 do
		local p_pos = vector.new(pos.x,pos.y+y,pos.z)
		local node = minetest.get_node(p_pos).name
		if node == "main:tree" then
			base_y = y
		end
	end
	--adjust pos
	pos = vector.new(pos.x,pos.y+base_y,pos.z)
	
	--destroy and get center of tree leaves
	for y = 0,5 do
		local p_pos = vector.new(pos.x,pos.y+y,pos.z)
		local node = minetest.get_node(p_pos).name
		if node == "main:tree" then
			top_y = y
			minetest.remove_node(p_pos)
			if not parent then
				parent = spawn_bvav_element(p_pos, {name="main:tree"})
				parent:get_luaentity().rotator = true
				parent:get_luaentity().rotate_dir = dir
				parent:get_luaentity().tree = 0
				parent:get_luaentity().leaves = 0
			else
				local child = spawn_bvav_element(p_pos, {name="main:tree"})
				child:get_luaentity().parent = parent			
				child:get_luaentity().relative = {x=0,y=y * bvav_settings.attach_scaling,z=0}
				child:set_attach(parent, "", {x=0,y=y * bvav_settings.attach_scaling,z=0}, {x=0,y=0,z=0})
				child:set_properties({visual_size = {x=bvav_settings.scaling, y=bvav_settings.scaling}})
				parent:get_luaentity().tree = parent:get_luaentity().tree + 1
			end
		end
	end
	
	local n_pos = vector.new(pos.x,pos.y+top_y,pos.z)
	local leaf_table = minetest.find_nodes_in_area(vector.subtract(n_pos,2), vector.add(n_pos,2), {"main:leaves"})
	for _,l_pos in pairs(leaf_table) do
		minetest.remove_node(l_pos)
		
		local x = l_pos.x - pos.x
		local y = l_pos.y - pos.y
		local z = l_pos.z - pos.z
		local child = spawn_bvav_element(l_pos, {name="main:leaves"})
		child:get_luaentity().parent = parent			
		child:get_luaentity().relative = {x=x * bvav_settings.attach_scaling,y=y * bvav_settings.attach_scaling,z=z * bvav_settings.attach_scaling}
		child:set_attach(parent, "", {x=x * bvav_settings.attach_scaling,y=y * bvav_settings.attach_scaling,z=z * bvav_settings.attach_scaling}, {x=0,y=0,z=0})
		child:set_properties({visual_size = {x=bvav_settings.scaling, y=bvav_settings.scaling}})
		parent:get_luaentity().leaves = parent:get_luaentity().leaves + 1
	end
	
	minetest.sound_play("tree_fall",{object=parent})
end
]]--
