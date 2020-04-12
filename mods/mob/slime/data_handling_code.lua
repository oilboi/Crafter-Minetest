--this controls how the mob saves and loads it's internal data

--save (happens when the mob despawns/server/singleplayer game shuts down)
slime.get_staticdata = function(self)
	return minetest.serialize({
		--range = self.range,
		hp = self.hp,
		hunger = self.hunger,
		hostile = self.hostile,
		hostile_timer = self.hostile_timer,
		death_animation_timer = self.death_animation_timer,
		dead = self.dead
	})
end

--load the mob's data when brough back into the world
slime.on_activate = function(self, staticdata, dtime_s)
	self.object:set_armor_groups({immortal = 1})
	--self.object:set_velocity({x = math.random(-5,5), y = 5, z = math.random(-5,5)})
	self.object:set_acceleration({x = 0, y = -9.81, z = 0})
	if string.sub(staticdata, 1, string.len("return")) == "return" then
		local data = minetest.deserialize(staticdata)
		if data and type(data) == "table" then
			--self.range = data.range
			self.hp = data.hp
			self.hunger = data.hunger
			self.hostile = data.hostile
			self.hostile_timer = data.hostile_timer
			self.death_animation_timer = data.death_animation_timer
			self.dead = data.dead
		end
	end
	
	--set up mob
	self.object:set_animation({x=0,y=0}, 1, 0, true)
	self.object:set_hp(self.hp)
	self.direction = vector.new(math.random()*math.random(-1,1),0,math.random()*math.random(-1,1))
	
	self.is_mob = true
	self.object:set_armor_groups({immortal = 1})
	--self.object:set_yaw(math.pi*math.random(-1,1)*math.random())
end


--this is the info on the mob
slime.debug_nametag = function(self,dtime)
	--we add in items we want to see in this list
	local debug_items = {"hostile_timer","hostile"}
	local text = ""
	for _,item in pairs(debug_items) do
		if self[item] ~= nil then
			text = text..item..": "..tostring(self[item]).."\n"
		end
	end
	self.child:set_nametag_attributes({
	color = "white",
	text = text
	})
end
