local minetest,math,vector,pairs,ItemStack,ipairs = minetest,math,vector,pairs,ItemStack,ipairs

local path = minetest.get_modpath("itemhandling")
dofile(path.."/magnet.lua")


local creative_mode = minetest.settings:get_bool("creative_mode")

--handle node drops
--survival
local meta
local careful
local fortune
local autorepair
local count
local name
local object
if not creative_mode then
	function minetest.handle_node_drops(pos, drops, digger)
		meta = digger:get_wielded_item():get_meta()
		--careful = meta:get_int("careful")
		fortune = 1--meta:get_int("fortune") + 1
		autorepair = meta:get_int("autorepair")
		--if careful > 0 then
		--	drops = {minetest.get_node(pos).name}
		--end
		for i = 1,fortune do
			for _,item in ipairs(drops) do

				if type(item) == "string" then
					count = 1
					name = item
				else
					count = item:get_count()
					name = item:get_name()
				end
				for i=1,count do
					object = minetest.add_item(pos, name)
					if object ~= nil then
						object:set_velocity({
							x=math.random(-2,2)*math.random(), 
							y=math.random(2,5), 
							z=math.random(-2,2)*math.random()
						})
					end
				end
			end
	        local experience_amount = minetest.get_item_group(minetest.get_node(pos).name,"experience")
	        if experience_amount > 0 then
	            minetest.throw_experience(pos, experience_amount)
	        end
		end
		--auto repair the item
		if autorepair > 0 and math.random(0,1000) < autorepair then
			local itemstack = digger:get_wielded_item()
			itemstack:add_wear(autorepair*-100)
			digger:set_wielded_item(itemstack)
		end
	end
--creative
else
	function minetest.handle_node_drops(pos, drops, digger)
	end
	minetest.register_on_dignode(function(pos, oldnode, digger)
		
		--if digger and digger:is_player() then
		--	local inv = digger:get_inventory()
		--	if inv and not inv:contains_item("main", oldnode) and inv:room_for_item("main", oldnode) then
		--		inv:add_item("main", oldnode)
		--	end
		--end
	end)
	minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
		return(itemstack:get_name())
	end)
end

local stack
local object
function minetest.throw_item(pos, item)
	-- Take item in any format
	stack = item
	object = minetest.add_entity(pos, "__builtin:item")	
	if object then
		object:get_luaentity():set_item(stack)
		object:set_velocity({
			x=math.random(-2,2)*math.random(), 
			y=math.random(2,5), 
			z=math.random(-2,2)*math.random()
		})
	end
	return object
end

local object
function minetest.throw_experience(pos, amount)
    for i = 1,amount do
        object = minetest.add_entity(pos, "experience:orb")
        if object then
            object:set_velocity({
				x=math.random(-2,2)*math.random(), 
				y=math.random(2,5), 
				z=math.random(-2,2)*math.random()
			})
        end
    end
	--return obj
end

--override drops
local dropper_is_player
local c_pos
local count
local sneak
local item
local object
local dir
function minetest.item_drop(itemstack, dropper, pos)
	dropper_is_player = dropper and dropper:is_player()
	c_pos = table.copy(pos)
	if dropper_is_player then
		sneak = dropper:get_player_control().sneak
		c_pos.y = c_pos.y + 1.2
		if not sneak then
			count = itemstack:get_count()
		else
			count = 1
		end
	else
		count = itemstack:get_count()
	end

	item = itemstack:take_item(count)
	object = minetest.add_item(c_pos, item)
	if object then
		if dropper_is_player then
			dir = dropper:get_look_dir()
			dir.x = dir.x * 2.9
			dir.y = dir.y * 2.9 + 2
			dir.z = dir.z * 2.9
			dir = vector.add(dir,dropper:get_player_velocity())
			object:set_velocity(dir)
			object:get_luaentity().dropped_by = dropper:get_player_name()
			object:get_luaentity().collection_timer = 0
		end
		return itemstack
	end
end


local stack
local itemname
local def
local set_item = function(self, item)
	stack = ItemStack(item or self.itemstring)
	self.itemstring = stack:to_string()
	if self.itemstring == "" then
		-- item not yet known
		return
	end

	itemname = stack:is_known() and stack:get_name() or "unknown"

	def = minetest.registered_nodes[itemname]

	self.object:set_properties({
		textures = {itemname},
		wield_item = self.itemstring,
		glow = def and def.light_source,
	})
end


local get_staticdata = function(self)
	return minetest.serialize({
		itemstring = self.itemstring,
		age = self.age,
		dropped_by = self.dropped_by,
		collection_timer = self.collection_timer,
		collectable = self.collectable,
		try_timer = self.try_timer,
		collected = self.collected,
		delete_timer = self.delete_timer,
		collector = self.collector,
		magnet_timer = self.magnet_timer,
	})
end

local data
local on_activate = function(self, staticdata, dtime_s)
	if string.sub(staticdata, 1, string.len("return")) == "return" then
		data = minetest.deserialize(staticdata)
		if data and type(data) == "table" then
			self.itemstring = data.itemstring
			self.age = (data.age or 0) + dtime_s
			self.dropped_by = data.dropped_by
			self.magnet_timer = data.magnet_timer
			self.collection_timer = data.collection_timer
			self.collectable = data.collectable
			self.try_timer = data.try_timer
			self.collected = data.collected
			self.delete_timer = data.delete_timer
			self.collector = data.collector
		end
	else
		self.itemstring = staticdata
	end
	self.object:set_armor_groups({immortal = 1})
	self.object:set_velocity({x = 0, y = 2, z = 0})
	self.object:set_acceleration({x = 0, y = -9.81, z = 0})
	set_item(self,self.itemstring)
end

local enable_physics = function(self)
	if not self.physical_state then
		self.physical_state = true
		self.object:set_properties({physical = true})
		self.object:set_velocity({x=0, y=0, z=0})
		self.object:set_acceleration({x=0, y=-9.81, z=0})
	end
end

local disable_physics = function(self)
	if self.physical_state then
		self.physical_state = false
		self.object:set_properties({physical = false})
		self.object:set_velocity({x=0, y=0, z=0})
		self.object:set_acceleration({x=0, y=0, z=0})
	end
end

local burn_nodes = {
	["fire:fire"]       = true,
	["nether:lava"]     = true,
	["nether:lavaflow"] = true,
	["main:lava"]       = true,
	["main:lavaflow"]   = true
}
local order = {
	{x=1, y=0, z=0}, {x=-1, y=0, z= 0},
	{x=0, y=0, z=1}, {x= 0, y=0, z=-1},
}
local collector
local pos
local pos2
local player_velocity
local direction
local distance
local multiplier
local velocity
local node
local is_stuck
local snode
local shootdir
local cnode
local cdef
local fpos
local vel
local def
local slip_factor
local change
local slippery
local i_node
local flow_dir
local item_step = function(self, dtime, moveresult)
	pos = self.object:get_pos()
	if not pos then
		return
	end

	--if item set to be collected then only execute go to player
	if self.collected == true then
		if not self.collector then
			self.object:remove()
			return
		end

		collector = minetest.get_player_by_name(self.collector)
		if collector then
			self.magnet_timer = self.magnet_timer + dtime	

			disable_physics(self)

			--get the variables
			pos2 = collector:get_pos()
			player_velocity = collector:get_player_velocity()
			pos2.y = pos2.y + 0.5
							
			distance = vector.distance(pos2,pos)

			if distance > 2 or distance < 0.3 or self.magnet_timer > 0.2 or self.old_magnet_distance and self.old_magnet_distance < distance then
				self.object:remove()
				return
			end

			direction = vector.normalize(vector.subtract(pos2,pos))

			multiplier = 10 - distance -- changed

			velocity = vector.add(player_velocity,vector.multiply(direction,multiplier))
						
			self.object:set_velocity(velocity)
			
			self.old_magnet_distance = distance

			return
		else
			-- the collector doesn't exist
			self.object:remove()
			return
		end
	end
	
	--allow entity to be collected after timer
	if self.collectable == false and self.collection_timer >= 2.5 then
		self.collectable = true
	elseif self.collectable == false then
		self.collection_timer = self.collection_timer + dtime
	end
			
	self.age = self.age + dtime
	if self.age > 300 then
		self.object:remove()
		return
	end
	-- polling eases the server load
	if self.poll_timer > 0 then
		self.poll_timer = self.poll_timer - dtime
		if self.poll_timer <= 0 then
			self.poll_timer = 0
		end
		return
	end

	if moveresult and moveresult.touching_ground and table.getn(moveresult.collisions) > 0 then
		node = minetest.get_node_or_nil(moveresult.collisions[1].node_pos)
	else
		node = nil
	end
	

	i_node = minetest.get_node_or_nil(pos)

	-- Remove nodes in 'ignore' and burns items
	if i_node then
		if i_node.name == "ignore" then
			self.object:remove()
			return
		elseif i_node and burn_nodes[i_node.name] then
			minetest.add_particlespawner({
				amount = 6,
				time = 0.001,
				minpos = pos,
				maxpos = pos,
				minvel = vector.new(-1,0.5,-1),
				maxvel = vector.new(1,1,1),
				minacc = {x=0, y=1, z=0},
				maxacc = {x=0, y=2, z=0},
				minexptime = 1.1,
				maxexptime = 1.5,
				minsize = 1,
				maxsize = 2,
				collisiondetection = false,
				vertical = false,
				texture = "smoke.png",
			})
			minetest.sound_play("fire_extinguish", {pos=pos,gain=0.3,pitch=math.random(80,100)/100})
			self.object:remove()
			return
		end
	end


	is_stuck = false
	snode = minetest.get_node_or_nil(pos)
	if snode and snode ~= "air" then
		snode = minetest.registered_nodes[snode.name] or {}
		is_stuck = (snode.walkable == nil or snode.walkable == true)
			and (snode.collision_box == nil or snode.collision_box.type == "regular")
			and (snode.node_box == nil or snode.node_box.type == "regular")
	end

	-- Push item out when stuck inside solid node
	if is_stuck then
		shootdir = nil
		-- Check which one of the 4 sides is free
		for o = 1, #order do
			cnode = minetest.get_node(vector.add(pos, order[o])).name
			cdef = minetest.registered_nodes[cnode] or {}
			if cnode ~= "ignore" and cdef.walkable == false then
				shootdir = order[o]
				break
			end
		end

		-- If none of the 4 sides is free, check upwards
		if not shootdir then
			shootdir = {x=0, y=1, z=0}
			cnode = minetest.get_node(vector.add(pos, shootdir)).name
			if cnode == "ignore" then
				shootdir = nil -- Do not push into ignore
			end
		end

		if shootdir then
			-- shove that thing outta there
			fpos = vector.round(pos)
			if shootdir.x ~= 0 then
				shootdir = vector.multiply(shootdir,0.74)
				self.object:move_to(vector.new(fpos.x+shootdir.x,pos.y,pos.z))
			elseif shootdir.y ~= 0 then
				shootdir = vector.multiply(shootdir,0.72)
				self.object:move_to(vector.new(pos.x,fpos.y+shootdir.y,pos.z))
			elseif shootdir.z ~= 0 then
				shootdir = vector.multiply(shootdir,0.74)
				self.object:move_to(vector.new(pos.x,pos.y,fpos.z+shootdir.z))
			end
			return
		end
	end


	flow_dir = flow(pos)
	
	if flow_dir then
		flow_dir = vector.multiply(flow_dir,10)
		local vel = self.object:get_velocity()
		local acceleration = vector.new(flow_dir.x-vel.x,flow_dir.y-vel.y,flow_dir.z-vel.z)
		acceleration = vector.multiply(acceleration, 0.01)
		self.object:add_velocity(acceleration)
		return
	end

	change = false
	-- Slide on slippery nodes
	def = node and minetest.registered_nodes[node.name]
	vel = self.object:get_velocity()
	if def and def.walkable then
		slippery = minetest.get_item_group(node.name, "slippery")
		if slippery ~= 0 then
			if math.abs(vel.x) > 0.2 or math.abs(vel.z) > 0.2 then
				-- Horizontal deceleration
				slip_factor = 4.0 / (slippery + 4)
				self.object:set_acceleration({
					x = -vel.x * slip_factor,
					y = -9.81,
					z = -vel.z * slip_factor
				})
				change = true
			elseif (vel.x ~= 0 or vel.z ~= 0) and math.abs(vel.x) <= 0.2 and math.abs(vel.z) <= 0.2 then
				self.object:set_velocity(vector.new(0,vel.y,0))
				self.object:set_acceleration(vector.new(0,-9.81,0))
			end
		elseif node then
			if math.abs(vel.x) > 0.2 or math.abs(vel.z) > 0.2 then
				self.object:add_velocity({
					x = -vel.x * 0.15,
					y = 0,
					z = -vel.z * 0.15
				})
				change = true
			elseif (vel.x ~= 0 or vel.z ~= 0) and math.abs(vel.x) <= 0.2 and math.abs(vel.z) <= 0.2 then
				self.object:set_velocity(vector.new(0,vel.y,0))
				self.object:set_acceleration(vector.new(0,-9.81,0))
			end
		end
	elseif vel.x ~= 0 or vel.y ~= 0 or vel.z ~= 0 then
		change = true
	end

	if change == false and self.poll_timer == 0 then
		self.poll_timer = 0.5
	end
end


minetest.register_entity(":__builtin:item", {
	initial_properties = {
		hp_max           = 1,
		visual           = "wielditem",
		physical         = true,
		textures         = {""},
		automatic_rotate = 1.5,
		is_visible       = true,
		pointable        = false,

		collide_with_objects = false,
		collisionbox = {-0.21, -0.21, -0.21, 0.21, 0.21, 0.21},
		selectionbox = {-0.21, -0.21, -0.21, 0.21, 0.21, 0.21},
		visual_size  = {x = 0.21, y = 0.21},
	},
	itemstring = "",
	moving_state = true,
	slippery_state = false,
	physical_state = true,
	-- Item expiry
	age = 0,
	-- Pushing item out of solid nodes
	force_out       = nil,
	force_out_start = nil,
	-- Collection Variables
	collection_timer = 2,
	collectable      = false,
	try_timer        = 0,
	collected        = false,
	delete_timer     = 0,
	-- Used for server delay
	magnet_timer = 0,
	poll_timer = 0,

	set_item = set_item,

	get_staticdata = function(self)
		return(get_staticdata(self))
	end,
	on_activate    = function(self, staticdata, dtime_s)
		on_activate(self, staticdata, dtime_s)
	end,

	on_step = function(self, dtime, moveresult)
		item_step(self, dtime, moveresult)
	end,
})


minetest.register_chatcommand("gimme", {
	params = "nil",
	description = "Spawn x amount of a mob, used as /spawn 'mob' 10 or /spawn 'mob' for one",
	privs = {server=true},
	func = function(name)
		local player = minetest.get_player_by_name(name)
		local pos = player:get_pos()
		pos.y = pos.y + 5
		pos.x = pos.x + 8
		for i = 1,1000 do
			minetest.throw_item(pos, "main:dirt")
		end
	end,
})
