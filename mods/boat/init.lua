--minetest.get_node_level(pos)
minetest.register_entity("boat:boat", {
	initial_properties = {
		hp_max = 1,
		physical = true,
		collide_with_objects = false,
		collisionbox = {-0.5, -0.35, -0.5, 0.5, 0.3, 0.5},
		visual = "mesh",
		mesh = "boat.obj",
		textures = {"boat.png"},
		visual_size = {x=3,y=3,z=3},
		is_visible = true,
	},
	
	driver = "",



	get_staticdata = function(self)
		return minetest.serialize({
			--itemstring = self.itemstring,
		})
	end,

	on_activate = function(self, staticdata, dtime_s)
		if string.sub(staticdata, 1, string.len("return")) == "return" then
			local data = minetest.deserialize(staticdata)
			if data and type(data) == "table" then
				--self.itemstring = data.itemstring
			end
		else
			--self.itemstring = staticdata
		end
		self.object:set_armor_groups({immortal = 1})
		self.object:set_velocity({x = 0, y = 0, z = 0})
		self.object:set_acceleration({x = 0, y = -9.81, z = 0})
	end,


	on_step = function(self, dtime)
		
	end,
})
