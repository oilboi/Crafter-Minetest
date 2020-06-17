local minetest,math,vector,pairs,ItemStack = minetest,math,vector,pairs,ItemStack

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

minetest.register_entity(":__builtin:item", {
	initial_properties = {
		hp_max = 1,

		physical = true,

		collide_with_objects = false,

		collisionbox = {-0.21, -0.21, -0.21, 0.21, 0.21, 0.21},

		selectionbox = {-0.21, -0.21, -0.21, 0.21, 0.21, 0.21},

		automatic_rotate = 1.5,

		visual = "wielditem",

		visual_size = {x = 0.21, y = 0.21},

		textures = {""},

		spritediv = {x = 1, y = 1},

		initial_sprite_basepos = {x = 0, y = 0},

		is_visible = true,

		pointable = false,
	},

	itemstring = "",
	moving_state = true,
	slippery_state = false,
	physical_state = true,
	-- Item expiry
	age = 0,
	-- Pushing item out of solid nodes
	force_out = nil,
	force_out_start = nil,
	--Collection Variables
	collection_timer = 2,
	collectable = false,
	try_timer = 0,
	collected = false,
	delete_timer = 0,

	set_item = function(self, item)
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

	end,

	get_staticdata = function(self)
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
	end,

	on_activate = function(self, staticdata, dtime_s)
		if string.sub(staticdata, 1, string.len("return")) == "return" then
			local data = minetest.deserialize(staticdata)
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
				--print("restored timer: "..self.collection_timer)
			end
		else
			self.itemstring = staticdata
			
			local x=math.random(-2,2)*math.random()
			local y=math.random(2,5)
			local z=math.random(-2,2)*math.random()
			self.object:set_velocity(vector.new(x,y,z))
		     -- print(self.collection_timer)
		end
		self.object:set_armor_groups({immortal = 1})
		self.object:set_velocity({x = 0, y = 2, z = 0})
		self.object:set_acceleration({x = 0, y = -9.81, z = 0})
		self:set_item()
	end,

	enable_physics = function(self)
		if not self.physical_state then
			self.physical_state = true
			self.object:set_properties({physical = true})
			self.object:set_velocity({x=0, y=0, z=0})
			self.object:set_acceleration({x=0, y=-9.81, z=0})
		end
	end,

	disable_physics = function(self)
		if self.physical_state then
			self.physical_state = false
			self.object:set_properties({physical = false})
			self.object:set_velocity({x=0, y=0, z=0})
			self.object:set_acceleration({x=0, y=0, z=0})
		end
	end,
	magnet_timer = 0,
	on_step = function(self, dtime,moveresult)
		--if item set to be collected then only execute go to player
		if self.collected == true then
			if not self.collector then
				self.object:remove()
				return
			end
			local collector = minetest.get_player_by_name(self.collector)
			if collector then
				self.magnet_timer = self.magnet_timer + dtime
				self.object:set_acceleration(vector.new(0,0,0))
				self.disable_physics(self)
				--get the variables
				local pos = self.object:get_pos()
				local pos2 = collector:get_pos()
				local player_velocity = collector:get_player_velocity()
				pos2.y = pos2.y + 0.5
								
				local direction = vector.normalize(vector.subtract(pos2,pos))
				local distance = vector.distance(pos2,pos)
								
				--remove if too far away
				if distance > 2 then
					distance = 0
				end
								
				local multiplier = 20 - distance
				local velocity = vector.multiply(direction,multiplier)
				
				local velocity = vector.add(player_velocity,velocity)
				
				self.object:set_velocity(velocity)
				
				if distance < 0.3 or self.magnet_timer > 0.2 or (self.old_magnet_distance and self.old_magnet_distance < distance) then
					self.object:remove()
				end
				
				self.old_magnet_distance = distance
				--self.delete_timer = self.delete_timer + dtime
				--this is where the item gets removed from world
				--if self.delete_timer > 1 then
				--	self.object:remove()
				--end
				return
			else
				--print(self.collector.." does not exist")
				self.object:remove()
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
			self.itemstring = ""
			self.object:remove()
			return
		end

		local pos = self.object:get_pos()
		--stop crashing if this ever fails
		if not pos then
			return
		end
		local node = minetest.get_node_or_nil({
			x = pos.x,
			y = pos.y + self.object:get_properties().collisionbox[2] - 0.05,
			z = pos.z
		})
		

		-- Remove nodes in 'ignore'
		if node and node.name == "ignore" then
			self.itemstring = ""
			self.object:remove()
			return
		end

		--burn inside fire nodes
		local node_inside = minetest.get_node_or_nil(pos)
		if node_inside and (node_inside.name == "fire:fire" or node_inside.name == "nether:lava" or node_inside.name == "nether:lavaflow" or node_inside.name == "main:lava" or node_inside.name == "main:lavaflow") then
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
			self.itemstring = ""
			self.object:remove()
			return
		end


		local is_stuck = false
		local snode = minetest.get_node_or_nil(pos)
		if snode then
			local sdef = minetest.registered_nodes[snode.name] or {}
			is_stuck = (sdef.walkable == nil or sdef.walkable == true)
				and (sdef.collision_box == nil or sdef.collision_box.type == "regular")
				and (sdef.node_box == nil or sdef.node_box.type == "regular")
		end

		-- Push item out when stuck inside solid node
		if is_stuck then
			local shootdir
			local order = {
				{x=1, y=0, z=0}, {x=-1, y=0, z= 0},
				{x=0, y=0, z=1}, {x= 0, y=0, z=-1},
			}

			-- Check which one of the 4 sides is free
			for o = 1, #order do
				local cnode = minetest.get_node(vector.add(pos, order[o])).name
				local cdef = minetest.registered_nodes[cnode] or {}
				if cnode ~= "ignore" and cdef.walkable == false then
					shootdir = order[o]
					break
				end
			end
			-- If none of the 4 sides is free, check upwards
			if not shootdir then
				shootdir = {x=0, y=1, z=0}
				local cnode = minetest.get_node(vector.add(pos, shootdir)).name
				if cnode == "ignore" then
					shootdir = nil -- Do not push into ignore
				end
			end

			if shootdir then
				-- Set new item moving speed accordingly
				local newv = vector.multiply(shootdir, 3)
				self:disable_physics()
				self.object:set_velocity(newv)

				self.force_out = newv
				self.force_out_start = vector.round(pos)
				return
			end
		elseif self.force_out then
			-- This code runs after the entity got a push from the above code.
			-- It makes sure the entity is entirely outside the solid node
			local c = self.object:get_properties().collisionbox
			local s = self.force_out_start
			local f = self.force_out
			local ok = (f.x > 0 and pos.x + c[1] > s.x + 0.5) or
				(f.y > 0 and pos.y + c[2] > s.y + 0.5) or
				(f.z > 0 and pos.z + c[3] > s.z + 0.5) or
				(f.x < 0 and pos.x + c[4] < s.x - 0.5) or
				(f.z < 0 and pos.z + c[6] < s.z - 0.5)
			if ok then
				-- Item was successfully forced out
				self.force_out = nil
				self:enable_physics()
			end
		end

		if not self.physical_state then
			return -- Don't do anything
		end

		-- Slide on slippery nodes
		local vel = self.object:get_velocity()
		local def = node and minetest.registered_nodes[node.name]
		local is_moving = (def and not def.walkable) or
			vel.x ~= 0 or vel.y ~= 0 or vel.z ~= 0
		local is_slippery = false

		if def and def.walkable then
			local slippery = minetest.get_item_group(node.name, "slippery")
			is_slippery = slippery ~= 0
			if is_slippery and (math.abs(vel.x) > 0.2 or math.abs(vel.z) > 0.2) then
				-- Horizontal deceleration
				local slip_factor = 4.0 / (slippery + 4)
				self.object:set_acceleration({
					x = -vel.x * slip_factor,
					y = 0,
					z = -vel.z * slip_factor
				})
			elseif vel.y == 0 then
				is_moving = false
				--[[
				local collisionbox = self.object:get_properties().collisionbox
				local move_y = collisionbox[2]
				if self.move_up == nil then
					self.move_up = true
				end
				local addition = 0
				if self.move_up == true then
					move_y = move_y + (dtime/10)
					addition = (dtime/8)
					if move_y > -0.21 then
						self.move_up = false
					end
				elseif self.move_up == false then
					move_y = move_y - (dtime/10)
					if move_y < -0.5 then
						self.move_up = true
					end
				end
				collisionbox[2] = move_y
				self.object:set_properties({collisionbox=collisionbox,physical = true})
				]]--
			end
		end

		if self.moving_state == is_moving and self.slippery_state == is_slippery then
			-- Do not update anything until the moving state changes
			return
		end

		self.moving_state = is_moving
		self.slippery_state = is_slippery
		
		if is_moving then
			self.object:set_acceleration({x = 0, y = -9.81, z = 0})
		else
			self.object:set_acceleration({x = 0, y = 0, z = 0})
			self.object:set_velocity({x = 0, y = 0, z = 0})
		end
	end,
})
