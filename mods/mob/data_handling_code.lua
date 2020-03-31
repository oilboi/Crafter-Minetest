--this controls how the mob saves and loads it's internal data

--save (happens when the mob despawns/server/singleplayer game shuts down)
mob.get_staticdata = function(self)
	return minetest.serialize({
		--range = self.range,
		hp = self.hp,
		hunger = self.hunger,	
	})
end

--load the mob's data when brough back into the world
mob.on_activate = function(self, staticdata, dtime_s)
	self.object:set_armor_groups({immortal = 1})
	--self.object:set_velocity({x = math.random(-5,5), y = 5, z = math.random(-5,5)})
	self.object:set_acceleration({x = 0, y = -9.81, z = 0})
	if string.sub(staticdata, 1, string.len("return")) == "return" then
		local data = minetest.deserialize(staticdata)
		if data and type(data) == "table" then
			--self.range = data.range
			self.hp = data.hp
			self.hunger = data.hunger
		end
	end
	
	--set up mob
	self.object:set_animation({x=5,y=15}, 1, 0, true)
	self.object:set_hp(self.hp)
	self.direction = vector.new(math.random()*math.random(-1,1),0,math.random()*math.random(-1,1))
	
	--set the head up
	local head = minetest.add_entity(self.object:get_pos(), "mob:head")
	if head then
		self.child = head
		self.child:get_luaentity().parent = self.object
		self.child:set_attach(self.object, "", vector.new(2.4,1.2,0), vector.new(180,0,180))
		self.head_rotation = vector.new(180,180,90)
		self.child:set_animation({x=90,y=90}, 15, 0, true)
	end
	self.is_mob = true
	--self.object:set_yaw(math.pi*math.random(-1,1)*math.random())
end
