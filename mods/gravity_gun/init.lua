local function convert_to_falling_node(pos)
	local obj = core.add_entity(pos, "__builtin:floating_node")
	if not obj then
		return false
	end
	local node = minetest.get_node(pos)
	
	node.level = core.get_node_level(pos)
	local meta = core.get_meta(pos)
	local metatable = meta and meta:to_table() or {}

	local def = core.registered_nodes[node.name]
	if def and def.sounds and def.sounds.fall then
		core.sound_play(def.sounds.fall, {pos = pos}, true)
	end

	obj:get_luaentity():set_node(node, metatable)
	core.remove_node(pos)
	return(obj)
end

local obj_table = {}

minetest.register_craftitem("gravity_gun:gravity_gun", {
	description = "Gravity Gun",
	inventory_image = "gravity_gun.png",
	stack_max = 1,
	range = 0,
	on_secondary_use = function(itemstack, user, pointed_thing)
		if not obj_table[user:get_player_name()] then
			local pos = user:get_pos()
			pos.y = pos.y + 1.485
			minetest.sound_play("gravitygun_attract",{object=user, pitch = math.random(80,100)/100})
			local dir = user:get_look_dir()
			local pos2 = vector.add(pos,vector.multiply(dir,20))
			local ray = minetest.raycast(pos, pos2, false, false)

			if ray then
				local pointed_thing = ray:next()
				
				if pointed_thing and pointed_thing.under then
					local obj = convert_to_falling_node(pointed_thing.under)
					if obj then
						obj:set_velocity(vector.new(0,0,0))
						obj:set_acceleration(vector.new(0,0,0))
						obj:get_luaentity().allow = false
						obj_table[user:get_player_name()] = obj
					end

				end
			end
		else
			minetest.sound_play("gravitygun_shot",{object=user, pitch = math.random(80,100)/100})
			local dir = user:get_look_dir()
			local force = vector.multiply(dir,40)
			obj_table[user:get_player_name()]:get_luaentity().allow = true
			obj_table[user:get_player_name()]:set_velocity(force)
			obj_table[user:get_player_name()] = nil
		end
	end,
})

minetest.register_globalstep(function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		if obj_table[player:get_player_name()] then
			if player:get_wielded_item():get_name() == "gravity_gun:gravity_gun" then
				local pos = player:get_pos()
				pos.y = pos.y + 1.485
				local dir = player:get_look_dir()
				local pos2 = vector.add(pos,vector.multiply(dir,3))
				obj_table[player:get_player_name()]:set_pos(pos2)
			else
				obj_table[player:get_player_name()]:set_acceleration(vector.new(0,-9.81,0))
				obj_table[player:get_player_name()]:get_luaentity().allow = true
				obj_table[player:get_player_name()] = nil
			end
		end
	end
end)

local builtin_shared = ...
local SCALE = 0.667

core.register_entity(":__builtin:floating_node", {
	initial_properties = {
		visual = "item",
		visual_size = {x = SCALE, y = SCALE, z = SCALE},
		textures = {},
		physical = true,
		is_visible = false,
		collide_with_objects = false,
		collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	},

	node = {},
	meta = {},

	set_node = function(self, node, meta)
		self.node = node
		meta = meta or {}
		if type(meta.to_table) == "function" then
			meta = meta:to_table()
		end
		for _, list in pairs(meta.inventory or {}) do
			for i, stack in pairs(list) do
				if type(stack) == "userdata" then
					list[i] = stack:to_string()
				end
			end
		end
		local def = core.registered_nodes[node.name]
		if not def then
			-- Don't allow unknown nodes to fall
			core.log("info",
				"Unknown falling node removed at "..
				core.pos_to_string(self.object:get_pos()))
			self.object:remove()
			return
		end
		self.meta = meta
		if def.drawtype == "torchlike" or def.drawtype == "signlike" then
			local textures
			if def.tiles and def.tiles[1] then
				local tile = def.tiles[1]
				if type(tile) == "table" then
					tile = tile.name
				end
				if def.drawtype == "torchlike" then
					textures = { "("..tile..")^[transformFX", tile }
				else
					textures = { tile, "("..tile..")^[transformFX" }
				end
			end
			local vsize
			if def.visual_scale then
				local s = def.visual_scale
				vsize = {x = s, y = s, z = s}
			end
			self.object:set_properties({
				is_visible = true,
				visual = "upright_sprite",
				visual_size = vsize,
				textures = textures,
				glow = def.light_source,
			})
		elseif def.drawtype ~= "airlike" then
			local itemstring = node.name
			if core.is_colored_paramtype(def.paramtype2) then
				itemstring = core.itemstring_with_palette(itemstring, node.param2)
			end
			local vsize
			if def.visual_scale then
				local s = def.visual_scale * SCALE
				vsize = {x = s, y = s, z = s}
			end
			self.object:set_properties({
				is_visible = true,
				wield_item = itemstring,
				visual_size = vsize,
				glow = def.light_source,
			})
		end
		-- Rotate entity
		if def.drawtype == "torchlike" then
			self.object:set_yaw(math.pi*0.25)
		elseif (node.param2 ~= 0 and (def.wield_image == ""
				or def.wield_image == nil))
				or def.drawtype == "signlike"
				or def.drawtype == "mesh"
				or def.drawtype == "normal"
				or def.drawtype == "nodebox" then
			if (def.paramtype2 == "facedir" or def.paramtype2 == "colorfacedir") then
				local fdir = node.param2 % 32
				-- Get rotation from a precalculated lookup table
				local euler = facedir_to_euler[fdir + 1]
				if euler then
					self.object:set_rotation(euler)
				end
			elseif (def.paramtype2 == "wallmounted" or def.paramtype2 == "colorwallmounted") then
				local rot = node.param2 % 8
				local pitch, yaw, roll = 0, 0, 0
				if rot == 1 then
					pitch, yaw = math.pi, math.pi
				elseif rot == 2 then
					pitch, yaw = math.pi/2, math.pi/2
				elseif rot == 3 then
					pitch, yaw = math.pi/2, -math.pi/2
				elseif rot == 4 then
					pitch, yaw = math.pi/2, math.pi
				elseif rot == 5 then
					pitch, yaw = math.pi/2, 0
				end
				if def.drawtype == "signlike" then
					pitch = pitch - math.pi/2
					if rot == 0 then
						yaw = yaw + math.pi/2
					elseif rot == 1 then
						yaw = yaw - math.pi/2
					end
				elseif def.drawtype == "mesh" or def.drawtype == "normal" then
					if rot >= 0 and rot <= 1 then
						roll = roll + math.pi
					else
						yaw = yaw + math.pi
					end
				end
				self.object:set_rotation({x=pitch, y=yaw, z=roll})
			end
		end
	end,

	get_staticdata = function(self)
		local ds = {
			node = self.node,
			meta = self.meta,
		}
		return core.serialize(ds)
	end,

	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal = 1})

		local ds = core.deserialize(staticdata)
		if ds and ds.node then
			self:set_node(ds.node, ds.meta)
		elseif ds then
			self:set_node(ds)
		elseif staticdata ~= "" then
			self:set_node({name = staticdata})
		end
	end,

	on_step = function(self, dtime)
		-- Set gravity
		if self.allow == true then
			local acceleration = self.object:get_acceleration()
			if not vector.equals(acceleration, {x = 0, y = -10, z = 0}) then
				self.object:set_acceleration({x = 0, y = -10, z = 0})
			end
			-- Turn to actual node when colliding with ground, or continue to move
			local pos = self.object:get_pos()
			-- Position of bottom center point
			local bcp = {x = pos.x, y = pos.y - 0.7, z = pos.z}
			-- 'bcn' is nil for unloaded nodes
			local bcn = core.get_node_or_nil(bcp)
			-- Delete on contact with ignore at world edges
			if bcn and bcn.name == "ignore" then
				self.object:remove()
				return
			end
			local bcd = bcn and core.registered_nodes[bcn.name]
			if bcn and
					(not bcd or bcd.walkable or
					(core.get_item_group(self.node.name, "float") ~= 0 and
					bcd.liquidtype ~= "none")) then
				if bcd and bcd.leveled and
						bcn.name == self.node.name then
					local addlevel = self.node.level
					if not addlevel or addlevel <= 0 then
						addlevel = bcd.leveled
					end
					if core.add_node_level(bcp, addlevel) == 0 then
						self.object:remove()
						return
					end
				elseif bcd and bcd.buildable_to and
						(core.get_item_group(self.node.name, "float") == 0 or
						bcd.liquidtype == "none") then
					core.remove_node(bcp)
					return
				end
				local np = {x = bcp.x, y = bcp.y + 1, z = bcp.z}
				-- Check what's here
				local n2 = core.get_node(np)
				local nd = core.registered_nodes[n2.name]
				-- If it's not air or liquid, remove node and replace it with
				-- it's drops
				if n2.name ~= "air" and (not nd or nd.liquidtype == "none") then
					core.remove_node(np)
					if nd and nd.buildable_to == false then
						-- Add dropped items
						local drops = core.get_node_drops(n2, "")
						for _, dropped_item in pairs(drops) do
							core.add_item(np, dropped_item)
						end
					end
					-- Run script hook
					for _, callback in pairs(core.registered_on_dignodes) do
						callback(np, n2)
					end
				end
				-- Create node and remove entity
				local def = core.registered_nodes[self.node.name]
				if def then
					core.add_node(np, self.node)
					if self.meta then
						local meta = core.get_meta(np)
						meta:from_table(self.meta)
					end
					if def.sounds and def.sounds.place then
						core.sound_play(def.sounds.place, {pos = np}, true)
					end
				end
				self.object:remove()
				core.check_for_falling(np)
				return
			end
			local vel = self.object:get_velocity()
			if vector.equals(vel, {x = 0, y = 0, z = 0}) then
				local npos = self.object:get_pos()
				self.object:set_pos(vector.round(npos))
			end
		elseif self.allow == nil then
			self.allow = true
		end
	end
})
