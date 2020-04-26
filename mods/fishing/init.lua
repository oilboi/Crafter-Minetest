 local players_fishing = {}
 
 minetest.register_craftitem("fishing:pole", {
	description = "Fishing Pole",
	inventory_image = "stick.png",
	stack_max = 1,
	range = 0,
	on_use = function(itemstack, user, pointed_thing)
		--minetest.sound_play("reload_gun",{object=user, pitch = math.random(80,100)/100})
		--print("reload")
	end,
	
	on_secondary_use = function(itemstack, user, pointed_thing)
		if not players_fishing[name] then
			local pos = user:get_pos()
			pos.y = pos.y + 1.625
			--minetest.sound_play("gun_shot",{object=user, pitch = math.random(80,100)/100})
			local dir = user:get_look_dir()
			local force = vector.multiply(dir,20)
			local name = user:get_player_name()
			local obj = minetest.add_entity(pos,"fishing:lure")
			if obj then
				minetest.sound_play("woosh",{pos=pos})
				obj:get_luaentity().player=name
				obj:get_luaentity().anchor=pos
				obj:set_velocity(force)
				players_fishing[name] = obj
				user:set_attach(obj, "", vector.new(0,65,0), vector.new(0,0,0))
			end
		end
	end,
})


local lure = {}
lure.initial_properties = {
	physical = true,
	collide_with_objects = false,
	collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
	visual = "mesh",
	visual_size = {x = 1, y = 1},
	mesh = "lure.b3d",
	textures = {
		"lure.png"
	},
	is_visible = true,
	pointable = false,
	--glow = -1,
	--automatic_face_movement_dir = 0.0,
	--automatic_face_movement_max_rotation_per_sec = 600,
}
lure.on_activate = function(self)
	self.object:set_acceleration(vector.new(0,-10,0))
end
lure.in_water = false
lure.interplayer = nil
lure.on_step = function(self, dtime)
	local pos = self.object:get_pos()
	local node = minetest.get_node(pos).name
	if node == "main:water" then
		self.in_water = true
		local new_pos = vector.floor(pos)
		new_pos.y = new_pos.y + 0.5
		self.object:move_to(vector.new(pos.x,new_pos.y,pos.z))
		self.object:set_acceleration(vector.new(0,0,0))
		self.object:set_velocity(vector.new(0,0,0))
		
	end
	if self.in_water == true then
		if self.player then
			local p = minetest.get_player_by_name(self.player)
			if p:get_player_control().jump then
				local vel = vector.direction(pos,self.anchor)
				self.object:set_velocity(vector.multiply(vel,2))
			else
				self.object:set_velocity(vector.new(0,0,0))
			end
			if vector.distance(self.anchor, p:get_pos()) < 0.5 then
				players_fishing[self.player] = nil
				self.object:remove()
			end
		end
	end
	if self.player == nil then
		self.object:remove()
	end
end
minetest.register_entity("fishing:lure", lure)
