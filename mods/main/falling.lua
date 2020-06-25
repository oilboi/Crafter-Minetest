local
minetest,vector,table,pairs,type,math
=
minetest,vector,table,pairs,type,math
--
-- Falling entity ("rewrite"")
--

local param_translation = {
	[0] = 0,
	[3] = math.pi/2,
	[2] = math.pi,
	[1] = math.pi*1.5,
}



minetest.register_entity(":__builtin:falling_node", {
	initial_properties = {
		visual = "wielditem",
		visual_size = {x = 0.667, y = 0.667},
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
		self.meta = meta


		self.object:set_properties({
			is_visible = true,
			textures = {node.name},
		})

		if node.param2 then
			self.object:set_rotation(vector.new(0,param_translation[node.param2],0))
		end
	end,

	get_staticdata = function(self)
		local ds = {
			node = self.node,
			meta = self.meta,
		}
		return minetest.serialize(ds)
	end,

	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal = 1})

		local ds = minetest.deserialize(staticdata)
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
		local acceleration = self.object:get_acceleration()
		if not vector.equals(acceleration, {x = 0, y = -10, z = 0}) then
			self.object:set_acceleration({x = 0, y = -10, z = 0})
		end
		-- Turn to actual node when colliding with ground, or continue to move
		local pos = self.object:get_pos()
		-- Position of bottom center point
		local bcp = {x = pos.x, y = pos.y - 0.7, z = pos.z}
		-- 'bcn' is nil for unloaded nodes
		local bcn = minetest.get_node_or_nil(bcp)
		-- Delete on contact with ignore at world edges
		if bcn and bcn.name == "ignore" then
			self.object:remove()
			return
		end
		local bcd = bcn and minetest.registered_nodes[bcn.name]
		if bcn and
				(not bcd or bcd.walkable or
				(minetest.get_item_group(self.node.name, "float") ~= 0 and
				bcd.liquidtype ~= "none")) then
			if bcd and bcd.leveled and
					bcn.name == self.node.name then
				local addlevel = self.node.level
				if not addlevel or addlevel <= 0 then
					addlevel = bcd.leveled
				end
				if minetest.add_node_level(bcp, addlevel) == 0 then
					self.object:remove()
					return
				end
			elseif bcd and bcd.buildable_to and
					(minetest.get_item_group(self.node.name, "float") == 0 or
					bcd.liquidtype == "none") then
				minetest.remove_node(bcp)
				return
			end
			local np = {x = bcp.x, y = bcp.y + 1, z = bcp.z}
			-- Check what's here
			local n2 = minetest.get_node(np)
			local nd = minetest.registered_nodes[n2.name]
			-- If it's not air or liquid, remove node and replace it with
			-- it's drops
			if n2.name ~= "air" and (not nd or nd.liquidtype == "none") then
				local drops = minetest.get_node_drops(self.node.name, "")
				if drops and table.getn(drops) > 0 then
					for _,droppy in pairs(drops) do
						minetest.throw_item(np,droppy)
					end
				else
					minetest.throw_item(np,self.node)
				end
				self.object:remove()
				return
			end
			-- Create node and remove entity
			local def = minetest.registered_nodes[self.node.name]
			if def then
				minetest.add_node(np, self.node)
				if self.meta then
					local meta = minetest.get_meta(np)
					meta:from_table(self.meta)
				end
				if def.sounds and def.sounds.fall then
					minetest.sound_play(def.sounds.fall, {pos = np}, true)
				end
			end
			self.object:remove()
			minetest.check_for_falling(np)
			return
		end

		local vel = self.object:get_velocity()
		if vector.equals(vel, {x = 0, y = 0, z = 0}) then
			local npos = self.object:get_pos()
			self.object:set_pos(vector.round(npos))
		end
	end
})
